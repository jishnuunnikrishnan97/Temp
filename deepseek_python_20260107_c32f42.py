import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock
from tqdm import tqdm
import logging
from typing import List, Optional, Dict, Any
import warnings
warnings.filterwarnings('ignore')

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MySQLtoPostgresETL:
    def __init__(self, mysql_conn_str: str, postgres_conn_str: str):
        """
        Initialize ETL processor with database connections
        
        Args:
            mysql_conn_str: MySQL connection string
            postgres_conn_str: PostgreSQL connection string
        """
        self.mysql_engine = create_engine(mysql_conn_str, pool_pre_ping=True, pool_recycle=3600)
        self.postgres_engine = create_engine(postgres_conn_str, pool_pre_ping=True, pool_recycle=3600)
        self.lock = Lock()
        self.processed_rows = 0
        self.processed_batches = 0
        
    def get_table_columns(self, table_name: str, source: str = 'mysql') -> List[str]:
        """Get column names from specified table"""
        try:
            if source == 'mysql':
                insp = inspect(self.mysql_engine)
            else:
                insp = inspect(self.postgres_engine)
            return [col['name'] for col in insp.get_columns(table_name)]
        except Exception as e:
            logger.error(f"Error getting columns for {table_name}: {e}")
            raise
    
    def get_date_range(self, table_name: str, date_column: str, end_date: str, 
                      start_date: Optional[str] = None) -> List[str]:
        """
        Generate month-end dates between start and end date
        
        Args:
            table_name: MySQL table name
            date_column: Name of the date column
            end_date: End date in 'YYYY-MM-DD' format
            start_date: Start date in 'YYYY-MM-DD' format (optional)
            
        Returns:
            List of month-end dates
        """
        try:
            with self.mysql_engine.connect() as conn:
                # Find min date if start_date not provided
                if not start_date:
                    query = f"""
                    SELECT MIN({date_column}) as min_date 
                    FROM {table_name}
                    WHERE {date_column} <= '{end_date}'
                    """
                    result = conn.execute(text(query))
                    min_date = result.fetchone()[0]
                    if not min_date:
                        return []
                    start_date = min_date.strftime('%Y-%m-%d')
                
                # Generate month-end dates
                start_dt = datetime.strptime(start_date, '%Y-%m-%d')
                end_dt = datetime.strptime(end_date, '%Y-%m-%d')
                
                month_ends = []
                current = start_dt.replace(day=1)
                
                while current <= end_dt:
                    # Get last day of month
                    next_month = current + relativedelta(months=1)
                    month_end = next_month - timedelta(days=1)
                    
                    if month_end <= end_dt:
                        month_ends.append(month_end.strftime('%Y-%m-%d'))
                    
                    current = next_month
                
                return month_ends
        except Exception as e:
            logger.error(f"Error getting date range: {e}")
            raise
    
    def find_date_column(self, table_name: str) -> str:
        """
        Automatically find a date/datetime column in the table
        
        Args:
            table_name: MySQL table name
            
        Returns:
            Name of date column
        """
        try:
            with self.mysql_engine.connect() as conn:
                # Query information schema for date columns
                query = f"""
                SELECT COLUMN_NAME, DATA_TYPE
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = '{table_name}'
                AND DATA_TYPE IN ('date', 'datetime', 'timestamp')
                ORDER BY ORDINAL_POSITION
                LIMIT 1
                """
                result = conn.execute(text(query))
                row = result.fetchone()
                
                if row:
                    return row[0]
                else:
                    raise ValueError(f"No date/datetime column found in table {table_name}")
        except Exception as e:
            logger.error(f"Error finding date column: {e}")
            raise
    
    def get_row_count(self, table_name: str, date_column: str, 
                     month_ends: List[str]) -> int:
        """Get total row count for all month ends"""
        try:
            with self.mysql_engine.connect() as conn:
                placeholders = ', '.join([f"'{date}'" for date in month_ends])
                query = f"""
                SELECT COUNT(*) 
                FROM {table_name}
                WHERE DATE({date_column}) IN ({placeholders})
                """
                result = conn.execute(text(query))
                return result.fetchone()[0]
        except Exception as e:
            logger.error(f"Error getting row count: {e}")
            raise
    
    def create_postgres_table(self, table_name: str, mysql_table: str, 
                            columns: List[str]):
        """Create PostgreSQL table if it doesn't exist"""
        try:
            with self.postgres_engine.connect() as conn:
                # Check if table exists
                insp = inspect(self.postgres_engine)
                if table_name in insp.get_table_names():
                    logger.info(f"Table {table_name} already exists in PostgreSQL")
                    return
                
                # Get MySQL table schema
                with self.mysql_engine.connect() as mysql_conn:
                    # Get sample row to infer types
                    sample_query = f"SELECT {', '.join(columns)} FROM {mysql_table} LIMIT 1"
                    sample_result = mysql_conn.execute(text(sample_query))
                    sample_row = sample_result.fetchone()
                    
                    if sample_row:
                        # Create table with appropriate types
                        column_defs = []
                        for i, col in enumerate(columns):
                            value = sample_row[i]
                            if isinstance(value, (int, np.integer)):
                                col_type = "BIGINT"
                            elif isinstance(value, float):
                                col_type = "DOUBLE PRECISION"
                            elif isinstance(value, datetime):
                                col_type = "TIMESTAMP"
                            else:
                                col_type = "TEXT"
                            column_defs.append(f"{col} {col_type}")
                        
                        create_query = f"""
                        CREATE TABLE IF NOT EXISTS {table_name} (
                            {', '.join(column_defs)}
                        )
                        """
                        conn.execute(text(create_query))
                        conn.commit()
                        logger.info(f"Created table {table_name} in PostgreSQL")
        except Exception as e:
            logger.error(f"Error creating PostgreSQL table: {e}")
            raise
    
    def process_batch(self, mysql_table: str, postgres_table: str, 
                     columns: List[str], date_column: str, month_end: str,
                     batch_size: int, offset: int, batch_num: int,
                     total_batches: int, pbar: tqdm) -> Dict[str, Any]:
        """Process a single batch of data"""
        try:
            # Pull batch from MySQL
            with self.mysql_engine.connect() as conn:
                columns_str = ', '.join(columns)
                query = f"""
                SELECT {columns_str}
                FROM {mysql_table}
                WHERE DATE({date_column}) = '{month_end}'
                LIMIT {batch_size} OFFSET {offset}
                """
                
                df = pd.read_sql_query(text(query), conn)
                
                if df.empty:
                    return {"rows": 0, "success": True}
                
                # Insert into PostgreSQL
                with self.postgres_engine.begin() as pg_conn:
                    df.to_sql(
                        postgres_table,
                        pg_conn,
                        if_exists='append',
                        index=False,
                        method='multi',
                        chunksize=1000
                    )
                
                # Update progress
                with self.lock:
                    self.processed_rows += len(df)
                    self.processed_batches += 1
                    pbar.update(len(df))
                    pbar.set_description(
                        f"Batch {batch_num}/{total_batches} | "
                        f"Total: {self.processed_rows:,} rows | "
                        f"Batches: {self.processed_batches:,}"
                    )
                
                return {"rows": len(df), "success": True}
                
        except Exception as e:
            logger.error(f"Error processing batch {batch_num}: {e}")
            return {"rows": 0, "success": False, "error": str(e)}
    
    def etl_pipeline(self, mysql_table: str, end_date: str, 
                    postgres_table: str, column_names: Optional[List[str]] = None,
                    start_date: Optional[str] = None, max_rows: Optional[int] = None,
                    num_workers: int = 4):
        """
        Main ETL pipeline function
        
        Args:
            mysql_table: MySQL source table name
            end_date: End date for data extraction (YYYY-MM-DD)
            postgres_table: PostgreSQL target table name
            column_names: List of columns to extract (optional)
            start_date: Start date for data extraction (optional)
            max_rows: Maximum rows per batch (optional)
            num_workers: Number of parallel workers
        """
        start_time = datetime.now()
        
        try:
            # Step 1: Find date column
            logger.info("Finding date column...")
            date_column = self.find_date_column(mysql_table)
            logger.info(f"Using date column: {date_column}")
            
            # Step 2: Generate month-end dates
            logger.info("Generating month-end dates...")
            month_ends = self.get_date_range(mysql_table, date_column, end_date, start_date)
            if not month_ends:
                logger.warning("No data found for the specified date range")
                return
            
            logger.info(f"Processing {len(month_ends)} month ends: {month_ends}")
            
            # Step 3: Get columns
            if not column_names:
                column_names = self.get_table_columns(mysql_table, 'mysql')
                logger.info(f"Using all {len(column_names)} columns")
            else:
                logger.info(f"Using specified {len(column_names)} columns")
            
            # Ensure date column is included
            if date_column not in column_names:
                column_names.append(date_column)
            
            # Step 4: Get total row count
            logger.info("Calculating total row count...")
            total_rows = self.get_row_count(mysql_table, date_column, month_ends)
            logger.info(f"Total rows to process: {total_rows:,}")
            
            if total_rows == 0:
                logger.warning("No rows found to process")
                return
            
            # Step 5: Create PostgreSQL table
            logger.info("Creating PostgreSQL table...")
            self.create_postgres_table(postgres_table, mysql_table, column_names)
            
            # Step 6: Determine batch size
            if not max_rows:
                # Auto-calculate batch size based on total rows
                if total_rows > 10000000:  # > 10M rows
                    batch_size = 100000
                elif total_rows > 1000000:  # > 1M rows
                    batch_size = 50000
                elif total_rows > 100000:  # > 100K rows
                    batch_size = 20000
                else:
                    batch_size = 5000
            else:
                batch_size = max_rows
            
            # Ensure batch size is reasonable
            batch_size = min(batch_size, 200000)  # Max 200K rows per batch
            
            logger.info(f"Using batch size: {batch_size:,}")
            logger.info(f"Using {num_workers} workers")
            
            # Step 7: Process data with parallel workers
            total_batches = 0
            batch_tasks = []
            
            # Create batches for each month end
            for month_end in month_ends:
                with self.mysql_engine.connect() as conn:
                    # Get count for this month end
                    count_query = f"""
                    SELECT COUNT(*) 
                    FROM {mysql_table}
                    WHERE DATE({date_column}) = '{month_end}'
                    """
                    result = conn.execute(text(count_query))
                    month_rows = result.fetchone()[0]
                    
                    if month_rows == 0:
                        continue
                    
                    # Calculate batches for this month
                    month_batches = (month_rows + batch_size - 1) // batch_size
                    total_batches += month_batches
                    
                    # Create batch tasks
                    for batch_num in range(month_batches):
                        offset = batch_num * batch_size
                        batch_tasks.append({
                            'mysql_table': mysql_table,
                            'postgres_table': postgres_table,
                            'columns': column_names,
                            'date_column': date_column,
                            'month_end': month_end,
                            'batch_size': batch_size,
                            'offset': offset,
                            'batch_num': len(batch_tasks) + 1
                        })
            
            logger.info(f"Total batches to process: {total_batches}")
            
            # Step 8: Initialize progress bar
            with tqdm(total=total_rows, desc="Starting ETL", unit="rows") as pbar:
                self.processed_rows = 0
                self.processed_batches = 0
                
                # Process batches in parallel
                with ThreadPoolExecutor(max_workers=num_workers) as executor:
                    # Submit all tasks
                    future_to_batch = {
                        executor.submit(
                            self.process_batch,
                            **task,
                            total_batches=total_batches,
                            pbar=pbar
                        ): task['batch_num']
                        for task in batch_tasks
                    }
                    
                    # Monitor progress
                    results = []
                    for future in as_completed(future_to_batch):
                        batch_num = future_to_batch[future]
                        try:
                            result = future.result()
                            results.append(result)
                        except Exception as e:
                            logger.error(f"Batch {batch_num} failed: {e}")
                            results.append({"success": False, "error": str(e)})
            
            # Step 9: Final statistics
            successful_batches = sum(1 for r in results if r.get('success', False))
            failed_batches = len(results) - successful_batches
            total_processed = sum(r.get('rows', 0) for r in results if r.get('success', False))
            
            elapsed_time = datetime.now() - start_time
            rows_per_second = total_processed / elapsed_time.total_seconds() if elapsed_time.total_seconds() > 0 else 0
            
            logger.info("\n" + "="*50)
            logger.info("ETL PROCESS COMPLETED")
            logger.info("="*50)
            logger.info(f"Total rows processed: {total_processed:,}")
            logger.info(f"Successful batches: {successful_batches:,}")
            logger.info(f"Failed batches: {failed_batches:,}")
            logger.info(f"Elapsed time: {elapsed_time}")
            logger.info(f"Processing speed: {rows_per_second:,.0f} rows/second")
            logger.info(f"Source: MySQL.{mysql_table}")
            logger.info(f"Target: PostgreSQL.{postgres_table}")
            logger.info("="*50)
            
            if failed_batches > 0:
                logger.warning(f"{failed_batches} batches failed. Check logs for details.")
            
        except Exception as e:
            logger.error(f"ETL pipeline failed: {e}")
            raise
        finally:
            # Cleanup
            self.mysql_engine.dispose()
            self.postgres_engine.dispose()

# Example usage function
def mysql_to_postgres_etl(
    mysql_conn_str: str,
    postgres_conn_str: str,
    mysql_table: str,
    end_date: str,
    postgres_table: str,
    column_names: Optional[List[str]] = None,
    start_date: Optional[str] = None,
    max_rows: Optional[int] = None,
    num_workers: int = 4
):
    """
    High-level function to execute MySQL to PostgreSQL ETL
    
    Args:
        mysql_conn_str: MySQL connection string
        postgres_conn_str: PostgreSQL connection string
        mysql_table: MySQL source table name
        end_date: End date for data extraction (YYYY-MM-DD)
        postgres_table: PostgreSQL target table name
        column_names: List of columns to extract (optional)
        start_date: Start date for data extraction (optional)
        max_rows: Maximum rows per batch (optional)
        num_workers: Number of parallel workers
    """
    etl = MySQLtoPostgresETL(mysql_conn_str, postgres_conn_str)
    etl.etl_pipeline(
        mysql_table=mysql_table,
        end_date=end_date,
        postgres_table=postgres_table,
        column_names=column_names,
        start_date=start_date,
        max_rows=max_rows,
        num_workers=num_workers
    )

# Example usage
if __name__ == "__main__":
    # Example connection strings (replace with actual credentials)
    mysql_conn = "mysql+pymysql://user:password@localhost:3306/database"
    postgres_conn = "postgresql://user:password@localhost:5432/database"
    
    # Execute ETL
    mysql_to_postgres_etl(
        mysql_conn_str=mysql_conn,
        postgres_conn_str=postgres_conn,
        mysql_table="large_table",
        end_date="2024-12-31",
        postgres_table="postgres_table",
        column_names=["col1", "col2", "date_column"],
        start_date="2024-01-01",
        max_rows=50000,
        num_workers=8
    )