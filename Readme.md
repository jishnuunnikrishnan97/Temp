```

Hey gpt i have a project written in python and that uses gemini's api to find leakages in financial contracts. But there are parts of the code that just use python. The Task at hand is to convert those python code into agentic prompt based python code


The below code is the custom models ive created for the project i have:
## models.py 
This is a function that is in that tools code:
from datetime import date, datetime
from decimal import Decimal
from enum import Enum
from typing import List, Optional, Dict, Any, Union
import uuid
import json
from pydantic import BaseModel, Field, validator
 
 
class FileType(str, Enum):
    pdf = "pdf"
    docx = "docx"
    zip = "zip"
 
class DocumentType(str, Enum):
    contract = "contract"
    invoice = "invoice"
    unknown = "unknown"
 
class ExtractionStatus(str, Enum):
    pending = "pending"
    extracted = "extracted"
    failed = "failed"
 
class ContractStatus(str, Enum):
    draft = "draft"
    active = "active"
    completed = "completed"
    unknown = "unknown" # Added unknown state
    expired = "expired" # Added expired state for contracts past their end date
 
class InvoiceStatus(str, Enum):
    pending = "pending" # Default state if not specified or determinable
    paid = "paid"
    overdue = "overdue"
    extracted = "extracted" # Internal status, maybe remove if redundant with Document.extraction_status
    draft = "draft"
    cancelled = "cancelled"
    unknown = "unknown" # Added unknown state
 
class LeakageIssueType(str, Enum):
    pricing_mismatch = "pricing_mismatch"
    service_scope = "service_scope"
    payment_terms_violation = "payment_terms_violation"
    duplication = "duplication" #Duplication or double-billing of services.
    inflation_violation = "inflation_violation" #Inflation clause violations.
    change_order_discrepancy = "change_order_discrepancy" #Change order discrepancies.
    unapproved_fees = "unapproved_fees" #Unapproved fees or charges.
    discount_misapplication = "discount_misapplication" #Discount misapplication.
    currency_conversion_error = "currency_conversion_error" #Currency conversion errors.
    other = "other" #other
 
class LeakageIssueSeverity(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"
 
class LeakageIssueStatus(str, Enum):
    open = "open"
    resolved = "resolved"
    dismissed = "dismissed"
 
# Simplified models with reduced nesting
class ContractParty(BaseModel):
    name: str = Field(description="Full legal name of the party involved in the contract.")
    role: Optional[str] = Field(None, description="Role of the party (e.g., 'Client', 'Provider', 'Customer', 'Vendor').")
    address: Optional[str] = Field(None, description="Full address of the party, if available.")
 
class ContractBillableItem(BaseModel):
    id: str = Field(default_factory=lambda: uuid.uuid4().hex)
    contract_id: str
    name: str = Field(description="Name or description of the billable service or product as stated in the contract (e.g., 'Senior Consultant', 'Software License').")
    sku: Optional[str] = Field(None, description="Stock Keeping Unit or unique identifier for the item, if applicable.")
    unit_of_measure: str = Field(description="Unit for billing (e.g., 'hour', 'day', 'month', 'unit', 'license').")
    contract_rate: float = Field(description="The agreed-upon rate for this item in the contract's standardized currency (e.g., USD).")
    original_rate: Optional[float] = Field(None, description="The rate as it appeared in the document *before* currency standardization, if applicable.")
    item_type: str = Field(description="Category of the item (e.g., 'Service', 'Software', 'Hardware', 'Labor').")
    is_recurring: bool = Field(False, description="Whether this item represents a recurring charge (e.g., monthly subscription).")
    creation_date: datetime = Field(default_factory=datetime.now)
    last_updated_date: datetime = Field(default_factory=datetime.now)
 
    def to_json(self) -> Dict[str, Any]:
        """Convert the contract billable item to a JSON-serializable dictionary for BigQuery."""
        item_dict = self.dict()
        # Convert datetime fields to ISO format strings
        item_dict["creation_date"] = item_dict["creation_date"].isoformat()
        item_dict["last_updated_date"] = item_dict["last_updated_date"].isoformat()
        return item_dict
 
# Forward declarations for type hints within models
class Contract(BaseModel):
    pass
 
class Invoice(BaseModel):
    pass
 
# Define ExtractionReturnType early if needed by Document, or use string forward reference
class ExtractionReturnType(BaseModel):
    contract: Optional[Contract] = None
    invoice: Optional[Invoice] = None
 
# Main Document model
class Document(BaseModel):
    id: str = Field(default_factory=lambda: uuid.uuid4().hex)
    filename: str
    file_type: FileType
    document_type: DocumentType = DocumentType.unknown
    upload_date: datetime
    extraction_status: ExtractionStatus
    content: Optional[str] = None # Make content field optional to handle NULL values
    extraction_result: Optional[ExtractionReturnType] = None # Use specific types
    gcs_blob_name: Optional[str] = None
 
    def model_dump(self, *args, **kwargs):
        dict = super().model_dump(*args, **kwargs)
        if "extraction_result" in dict:
            del dict["extraction_result"]
        return dict
 
 
# Simplified Contract model with flatter structure
class Contract(BaseModel):
    id: str = Field(default_factory=lambda: uuid.uuid4().hex)
    document_id: str
    contract_number: str = Field(description="Unique identifier or number for the contract (e.g., 'AR3086').")
    start_date: date = Field(description="The effective start date of the contract (YYYY-MM-DD).")
    end_date: Optional[date] = Field(None, description="The expiration or termination date of the contract (YYYY-MM-DD), if specified.")
    client_name: str = Field(description="The name of the client or customer entity in the contract.")
    provider_name: Optional[str] = Field(None, description="The name of the service provider or vendor entity in the contract.") # Added provider
    service_description: str = Field(description="A brief summary of the services or goods provided under the contract.")
    payment_terms: str = Field(description="Payment conditions (e.g., 'Net 30', 'Due upon receipt').")
    total_value: float | None = Field(description="Estimated or fixed total value of the contract in the standardized currency (e.g., USD), if specified.")
    original_total_value: Optional[float] = Field(None, description="Total value as it appeared in the document *before* currency standardization, if applicable.")
    currency: str = Field(description="Standardized 3-letter ISO currency code (e.g., 'USD', 'EUR', 'GBP').")
    original_currency: Optional[str] = Field(None, description="Currency symbol or code as it appeared in the document (e.g., '$', '€', '£').")
    status: ContractStatus = Field(ContractStatus.active, description="Current status of the contract (e.g., 'active', 'completed'). Infer 'active' if start/end dates encompass the present, default to 'unknown'.")
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    description: Optional[str] = Field(None, description="Longer description or abstract of the contract's purpose.")
    renewal_date: Optional[date] = Field(None, description="Date for the next renewal review or automatic renewal (YYYY-MM-DD).")
    terms_and_conditions: str = Field(description="Key items both parties agree upon.")
 
    # Use the specific ContractBillableItem model
    billable_items: List[ContractBillableItem] = Field(description="List of specific services or products with rates defined in the contract. Do not leave empty.")
    parties: List[ContractParty] = Field(default_factory=list, description="List of all parties involved in the contract with their roles.")
 
    # Simple text fields for other contract details
    additional_notes: str = Field(description="Scope of work and Agreed Items")
 
    # Flat structure for rate increases
    rate_increase_percentage: Optional[float] = Field(None, description="Percentage for periodic rate increases, if specified.")
    rate_increase_frequency_months: Optional[int] = Field(None, description="Frequency of rate increases in months, if specified.")
    rate_increase_next_date: Optional[date] = Field(None, description="Date of the next scheduled rate increase (YYYY-MM-DD).")
 
    # Rebate info as text
    rebate_structure_text: Optional[str] = Field(None, description="Description of any rebate structures or conditions.")
 
    # SLA as text
    sla_info: str = Field(description="Summary of Service Level Agreements (SLAs), if present.")
 
    # Simplified termination info
    termination_notice_days: Optional[int] = Field(None, description="Required notice period for contract termination in days.")
    termination_conditions: str = Field(description="Summary of conditions under which the contract can be terminated.")
 
    # Other contract details as text fields
    limitation_of_liability_text: str = Field(description="Summary of limitation of liability clauses.")
    dispute_resolution_text: str = Field(description="Description of the dispute resolution process.")
    data_protection_text: str = Field(description="Summary of data protection or privacy clauses.")
 
    @validator('currency')
    def validate_currency(cls, v):
        if v and len(v) != 3:
            # Basic check, could add a list of valid ISO codes
             # print(f"Warning: Currency '{v}' is not a 3-letter code. Attempting to standardize or defaulting.")
             # Add logic here to attempt standardization (e.g., '$' -> 'USD') or raise error
             # For now, let's raise ValueError for simplicity
             raise ValueError('Currency must be a 3-letter ISO code (e.g., USD)')
        return v.upper() # Standardize to uppercase
 
    def to_json(self) -> Dict[str, Any]:
        """Convert the contract to a JSON-serializable dictionary for BigQuery."""
        # Use model_dump for Pydantic v2+
        contract_dict = self.model_dump(exclude={"billable_items", "parties"})
 
        # Manual serialization for specific formats needed by BigQuery
        contract_dict["status"] = str(self.status.value) # Use .value for enums
 
        # Convert date fields to ISO format strings safely
        if self.start_date:
            contract_dict["start_date"] = self.start_date.isoformat()
        if self.end_date:
            contract_dict["end_date"] = self.end_date.isoformat()
        if self.renewal_date:
            contract_dict["renewal_date"] = self.renewal_date.isoformat()
        if self.rate_increase_next_date:
            contract_dict["rate_increase_next_date"] = self.rate_increase_next_date.isoformat()
 
        # Convert datetime fields to ISO format strings
        contract_dict["created_at"] = self.created_at.isoformat()
        contract_dict["updated_at"] = self.updated_at.isoformat()
 
        # Handle nested lists - serialize each item to JSON STRING as required by BigQuery schema
        # BigQuery expects REPEATED STRING fields for billable_items and parties
        contract_dict["billable_items"] = [json.dumps(item.to_json()) for item in self.billable_items if isinstance(item, ContractBillableItem)]
        contract_dict["parties"] = [json.dumps(party.model_dump()) for party in self.parties if isinstance(party, ContractParty)]
 
        return contract_dict
 
 
# Invoice models
class InvoiceBillableItem(BaseModel):
    id: str = Field(default_factory=lambda: uuid.uuid4().hex)
    invoice_id: str
    name: str = Field(description="Description of the invoiced item or service (e.g., 'Cloud Architect Lead', 'Managed Security Services Bundle').")
    sku: Optional[str] = Field(None, description="SKU or item code, if provided.")
    unit_of_measure: str = Field(description="Unit of the invoiced item (e.g., 'hrs', 'nodes', 'unit').")
    invoiced_rate: float = Field(description="Rate charged for one unit in the standardized currency (e.g., USD).")
    original_rate: Optional[float] = Field(None, description="Rate as it appeared in the document *before* currency standardization, if applicable.")
    quantity: float = Field(description="Number of units invoiced.")
    line_item_total: float = Field(description="Total amount for this line item (rate * quantity) in the standardized currency (e.g., USD).")
    original_line_item_total: Optional[float] = Field(None, description="Line total as it appeared in the document *before* currency standardization, if applicable.")
    item_type: str = Field("Service", description="Type of item (e.g., 'Service', 'Product', 'Labor', 'Bundle').")
    additional_notes: Optional[str] = Field(None, description="Any specific notes related to this line item.")
 
    def to_json(self) -> Dict[str, Any]:
        """Convert the invoice billable item to a JSON-serializable dictionary for BigQuery."""
        return self.model_dump() # Use model_dump for Pydantic v2+
 
class Invoice(BaseModel):
    id: str = Field(default_factory=lambda: uuid.uuid4().hex)
    contract_id: Optional[str] = Field(None, description="Associated Contract ID, if identifiable (e.g., 'AR3086').") # Link to contract (if known)
    document_id: str
    invoice_number: str = Field(description="Unique identifier for the invoice (e.g., 'ACC-2023-0901').")
    issue_date: date = Field(description="Date the invoice was issued (YYYY-MM-DD). Use null if not found.")
    due_date: Optional[date] = Field(None, description="Date the payment is due (YYYY-MM-DD). Use null if not found.")
    currency: str = Field(description="Standardized 3-letter ISO currency code (e.g., 'USD').")
    original_currency: Optional[str] = Field(None, description="Currency symbol or code as found in the document (e.g., '$').")
    status: InvoiceStatus = Field(InvoiceStatus.extracted, description="Status of the invoice (e.g., 'pending', 'paid'). Default to 'unknown' or 'pending' if dates are in the future/past.")
    payment_date: Optional[date] = Field(None, description="Date the invoice was paid (YYYY-MM-DD), if specified.")
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    provider: str = Field(description="Name of the company issuing the invoice (e.g., 'Accenture').")
    customer: str = Field(description="Name of the company or entity receiving the invoice (e.g., 'State of Oklahoma Office of Management and Enterprise Services').")
    notes: Optional[str] = Field(None, description="General notes section from the invoice.")
    payment_terms: str = Field(description="Payment terms specified (e.g., 'Net 30 days').")
 
    # Use the specific InvoiceBillableItem model
    billable_items: List[InvoiceBillableItem] = Field(description="List of detailed line items from the invoice. Should NOT be empty.")
    purchase_order_number: Optional[str] = Field(None, description="Purchase Order (PO) number associated with the invoice, if any.")
    discount_amount: float = Field(0.0, description="Total discount amount applied to the invoice in the standardized currency (e.g., USD).")
    tax_amount: float = Field(0.0, description="Total tax amount applied to the invoice in the standardized currency (e.g., USD).")
    # invoice_total: float = Field(description="The final total amount due on the invoice in the standardized currency (e.g., USD). Should equal subtotal - discount + tax.")
    original_invoice_total: Optional[float] = Field(None, description="Total amount as it appeared in the document *before* currency standardization, if applicable.")
    contract_name: Optional[str] = Field(None, description="Name or reference to the contract mentioned in the invoice (e.g., 'NASPO ValuePoint Cloud Solutions Master Agreement #AR3086').")
 
    @property
    def invoice_subtotal(self):
        return sum([bi.line_item_total for bi in self.billable_items])
   
    @property
    def invoice_total(self):
        return self.invoice_subtotal - self.discount_amount + self.tax_amount
       
 
    @validator('currency')
    def validate_currency(cls, v):
        if v and len(v) != 3:
             # print(f"Warning: Currency '{v}' is not a 3-letter code. Attempting to standardize or defaulting.")
             # Add logic here to attempt standardization (e.g., '$' -> 'USD') or raise error
             raise ValueError('Currency must be a 3-letter ISO code (e.g., USD)')
        return v.upper() # Standardize to uppercase
 
    # # Add validation to ensure total calculation seems plausible if possible
    # @validator('invoice_total')
    # def check_total(cls, v, values):
    #     # Ensure 'v' (invoice_total) is a float
    #     if not isinstance(v, (float, int)):
    #         # Removed print statement for performance
    #         return v # Return original value if non-numeric to avoid crashing validation
 
    #     subtotal = values.get('invoice_subtotal')
    #     discount = values.get('discount_amount', 0.0) or 0.0 # handle None
    #     tax = values.get('tax_amount', 0.0) or 0.0 # handle None
 
    #     # Ensure components are numeric before calculation
    #     if isinstance(subtotal, (float, int)):
    #         calculated_total = float(subtotal) - float(discount) + float(tax)
    #         # Allow for small rounding differences
    #         if not abs(float(v) - calculated_total) < 0.02: # Tolerance of 2 cents
    #              # Removed print statement for performance
    #              # Decide if this should raise ValueError or just be a warning
    #              # raise ValueError('Invoice total does not match subtotal - discount + tax')
    #              pass
    #     return v # Must return the value for the validator
 
 
    # # Calculate subtotal from line items if not extracted
    # @validator('invoice_subtotal', always=True, pre=True)
    # def calculate_subtotal_if_missing(cls, v, values):
    #     """Calculate subtotal from line items if not explicitly extracted."""
    #     if v is None: # Only calculate if subtotal wasn't extracted
    #         billable_items = values.get('billable_items', [])
    #         # Check if billable_items is a list and its elements have the required attribute
    #         if isinstance(billable_items, list) and billable_items:
    #              # Ensure items are the correct type or have the attribute before summing
    #              if all(hasattr(item, 'line_item_total') and isinstance(getattr(item, 'line_item_total'), (float, int)) for item in billable_items):
    #                  calculated_subtotal = sum(item.line_item_total for item in billable_items)
    #                  # Removed print statement for performance
    #                  return calculated_subtotal
    #              else:
    #                   # Removed print statement for performance
    #                   return None # Return None if calculation fails
    #         else:
    #              return None # Return None if no items
    #     # If v was provided (not None), return the extracted value
    #     return v
 
 
    def to_json(self) -> Dict[str, Any]:
        """Convert the invoice to a JSON-serializable dictionary for BigQuery."""
        # Use model_dump for Pydantic v2+
        invoice_dict = self.model_dump(exclude={"billable_items", "invoice_subtotal"})
 
        # Manual serialization for specific formats needed by BigQuery
        invoice_dict["status"] = str(self.status.value) # Use .value for enums
 
        # Convert date fields to ISO format strings safely
        if self.issue_date:
            invoice_dict["issue_date"] = self.issue_date.isoformat()
        if self.due_date:
            invoice_dict["due_date"] = self.due_date.isoformat()
        if self.payment_date:
            invoice_dict["payment_date"] = self.payment_date.isoformat()
 
        # Convert datetime fields to ISO format strings
        invoice_dict["created_at"] = self.created_at.isoformat()
        invoice_dict["updated_at"] = self.updated_at.isoformat()
 
        # Handle nested lists - serialize each item to JSON STRING as required by BigQuery schema
        # BigQuery expects REPEATED STRING fields for billable_items
        invoice_dict["billable_items"] = [json.dumps(item.to_json()) for item in self.billable_items if isinstance(item, InvoiceBillableItem)]
 
        return invoice_dict
   
    @classmethod
    def from_bigquery(cls, data: Dict[str, Any]) -> 'Invoice':
        """Create an Invoice object from BigQuery data."""
        # Make a copy of the data to avoid modifying the original
        invoice_data = data.copy()
       
        # Process billable_items if they exist
        if "billable_items" in invoice_data and invoice_data["billable_items"]:
            billable_items_list = []
            for item_json in invoice_data["billable_items"]:
                if isinstance(item_json, str):
                    try:
                        item_dict = json.loads(item_json)
                        billable_items_list.append(InvoiceBillableItem(**item_dict))
                    except json.JSONDecodeError:
                        # If it's not valid JSON, it might be just an ID reference
                        pass
            invoice_data["billable_items"] = billable_items_list
       
        # Fix status if it's in the format "InvoiceStatus.xxx"
        if "status" in invoice_data and isinstance(invoice_data["status"], str):
            if invoice_data["status"].startswith("InvoiceStatus."):
                invoice_data["status"] = invoice_data["status"].replace("InvoiceStatus.", "")
       
        return cls(**invoice_data)
 
 
class LeakageIssue(BaseModel):
    id: str = Field(default_factory=lambda: uuid.uuid4().hex)
    contract_id: str
    invoice_id: str
    issue_type: LeakageIssueType
    description: str = Field(description="Short, one sentence, summary of the issue.")
    long_description: str = Field(description="Detailed, 2-4 sentence, description of the issue.")
    severity: LeakageIssueSeverity
    status: LeakageIssueStatus
    leakage_amount: float = Field(description="The total financial impact of the issue in the standardized currency (e.g., USD). For example, a rate discrepancy of $10 with 5 units purchased will have a leakage amount of 50.0. Should NOT be 0.0 in most cases.")
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
 
    def to_json(self) -> Dict[str, Any]:
        """Convert the leakage issue to a JSON-serializable dictionary for BigQuery."""
        # Use model_dump for Pydantic v2+
        issue_dict = self.model_dump()
 
        # Manual serialization for specific formats needed by BigQuery
        issue_dict["issue_type"] = str(self.issue_type.value)
        issue_dict["severity"] = str(self.severity.value)
        issue_dict["status"] = str(self.status.value)
 
        # Convert datetime fields to ISO format strings
        issue_dict["created_at"] = self.created_at.isoformat()
        issue_dict["updated_at"] = self.updated_at.isoformat()
 
        return issue_dict
 
# Update forward refs after all dependent models are defined
# This helps Pydantic resolve the type hints correctly
Contract.update_forward_refs()
Invoice.update_forward_refs()
Document.update_forward_refs()
ExtractionReturnType.update_forward_refs()


# Extraction Service
async def run_extraction_service(document_id: str, contract_id: Optional[str] = None) -> ExtractionReturnType:
    response = ExtractionReturnType()
    document = document_manager.get(document_id)
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
 
    if document.document_type == DocumentType.contract:
        contract = await parse_doc(document.content, "contract")
        contract.document_id = document_id
        contract.id = str(uuid.uuid4())
        for item in contract.billable_items:
            item.id = str(uuid.uuid4())
            item.contract_id = contract.id
        contract_manager.put(contract)
        response.contract = contract
 
    elif document.document_type == DocumentType.invoice:
        invoice = await parse_doc(document.content, "invoice")
        invoice.document_id = document_id
        invoice.id = str(uuid.uuid4())
        invoice.status = InvoiceStatus.extracted
        if contract_id:
            contract = contract_manager.get(contract_id)
            invoice.contract_id = contract.id
            invoice.contract_name = f"{contract.contract_number} - {contract.client_name}"
        for item in invoice.billable_items:
            item.id = str(uuid.uuid4())
            item.invoice_id = invoice.id
        invoice_manager.put(invoice)
        response.invoice = invoice
 
    else:
        document.extraction_status = ExtractionStatus.failed
        document_manager.update(document)
        raise HTTPException(status_code=400, detail=f"Unknown document type: {document.document_type}")
 
    document.extraction_status = ExtractionStatus.extracted
    document_manager.update(document)
    return response


the code below is the function i want to convert into a prompt based python code:
async def run_extraction_service(document_id: str, contract_id: Optional[str] = None) -> ExtractionReturnType:
    response = ExtractionReturnType()
    document = document_manager.get(document_id)
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
 
    if document.document_type == DocumentType.contract:
        contract = await parse_doc(document.content, "contract")
        contract.document_id = document_id
        contract.id = str(uuid.uuid4())
        for item in contract.billable_items:
            item.id = str(uuid.uuid4())
            item.contract_id = contract.id
        contract_manager.put(contract)
        response.contract = contract
 
    elif document.document_type == DocumentType.invoice:
        invoice = await parse_doc(document.content, "invoice")
        invoice.document_id = document_id
        invoice.id = str(uuid.uuid4())
        invoice.status = InvoiceStatus.extracted
        if contract_id:
            contract = contract_manager.get(contract_id)
            invoice.contract_id = contract.id
            invoice.contract_name = f"{contract.contract_number} - {contract.client_name}"
        for item in invoice.billable_items:
            item.id = str(uuid.uuid4())
            item.invoice_id = invoice.id
        invoice_manager.put(invoice)
        response.invoice = invoice
 
    else:
        document.extraction_status = ExtractionStatus.failed
        document_manager.update(document)
        raise HTTPException(status_code=400, detail=f"Unknown document type: {document.document_type}")
 
    document.extraction_status = ExtractionStatus.extracted
    document_manager.update(document)
    return response

The Goal is to rewrite this function in such a way that the code prompts Gemini to extract the details from the input using the existing custom models ive built and return the same output as the current code is returning, without changing its name or the output it provides

```
