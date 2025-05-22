```
##subagent/contract/contract.py:
from google.adk.agents import Agent
from ai_contract_intelligence.sub_agents.contract import contract_prompt
contract_agent = Agent(
    name='contract',
    model='gemini-2.0-flash',
    description="A system that identifies and extracts relevant information from contract documents.",
    instruction=contract_prompt.PROMPT,    
)

##subagent/contract/prompt.py:
PROMPT= """
                    **Task:** Extract comprehensive information from the provided contract text and structure format.
                    **Contract Text:**
                    ```                    
                    ```
                    **Extraction Guidelines:**

                    1.  **Identify Core Fields:** Extract the following primary contract details:
                        *   `contract_number`: Unique ID (e.g., "AR3086").
                        *   `start_date`: Effective date (Format: YYYY-MM-DD).
                        *   `end_date`: Termination date, if specified (Format: YYYY-MM-DD). Use null if indefinite or not found.
                        *   `client_name`: The primary customer/client entity.
                        *   `provider_name`: The primary service provider/vendor entity (e.g., "Accenture").
                        *   `service_description`: Brief summary of the contract's purpose/scope.
                        *   `payment_terms`: Conditions for payment (e.g., "Net 30").
                        *   `total_value`: Overall contract value, if stated.
                        *   `renewal_date`: Next renewal date, if applicable (Format: YYYY-MM-DD).
                        *   `terms_and_conditions`: A summary if possible, or reference.
                        *   `description`: Longer abstract or description.

                    2.  **Currency Standardization:**
                        *   Identify the currency used (e.g., '$', 'USD').
                        *   Store the original symbol/code in `original_currency`.
                        *   Standardize the main `currency` field to its 3-letter ISO code (e.g., 'USD'). Assume 'USD' if '$' is used without other context.
                        *   All monetary fields (`total_value`, `contract_rate`, etc.) should be represented in this standardized currency. Store original values in `original_...` fields if needed.

                    3.  **Extract Parties:** Identify all named parties involved. For EACH party:
                        *   `name`: Full legal name.
                        *   `role`: Their role (e.g., "Client", "Provider", "Customer", "Vendor"). Infer if not explicit.
                        *   `address`: Full address if available.
                        *   Populate the `parties` list.

                    4.  **Extract Billable Items/Rates:** Thoroughly search the entire document for ANY pricing information, rate tables, service listings, or product catalogs. 
                            Look for sections with titles like "Pricing", "Rates", "Services", "Products", "Fees", "Charges", "Price List", etc. For EACH distinct billable item found:
                        *   `name`: Description of the service or product (e.g., "Senior Manager", "Cloud Architect Lead", "AWS Key Managed Services", "IaaS Management Services", "RedShift", "RDS Oracle Databases").
                        *   `sku`: If an identifier like a SKU or code is present (e.g., "ACN-TSTS-001").
                        *   `unit_of_measure`: Unit for the rate (e.g., "hour", "day", "month", "VM per month", "Managed Service Unit", "Each", "Bundle").
                        *   `contract_rate`: The agreed price per unit in the standardized currency (e.g., 350.0, 44571.0, 241.0).
                        *   `item_type`: Category of the item (e.g., "Labor", "Service", "Software", "Hardware", "Bundle").
                        *   `is_recurring`: True if it's a periodic fee (e.g., monthly subscription, annual license), False otherwise (common for hourly rates).
                        *   Be extremely thorough and extract ALL billable items, even if they appear in different sections or formats throughout the document.
                        *   Pay special attention to tables, lists, and structured sections that contain pricing information.
                        *   For cloud services contracts, look for items like managed services, infrastructure components, database services, etc.

                    5.  **Extract Other Clauses:** Summarize information related to:
                        *   Rate Increases (`rate_increase_percentage`, `rate_increase_frequency_months`, `rate_increase_next_date`).
                        *   Rebates (`rebate_structure_text`).
                        *   SLAs (`sla_info`).
                        *   Termination (`termination_notice_days`, `termination_conditions`).
                        *   Liability (`limitation_of_liability_text`).
                        *   Dispute Resolution (`dispute_resolution_text`).
                        *   Data Protection (`data_protection_text`).
                        *   `additional_notes`: Any other significant details not covered elsewhere.

                    6.  **Determine Status:**
                        *   Set the `status` field. Use 'active' if the current date falls between `start_date` and `end_date` (or if `end_date` is null/future). Use 'completed' if `end_date` is past. Use 'draft' if indicated. Default to 'unknown'.

                    7.  **Accuracy and Completeness:**
                        *   Extract values precisely. Use `null` or `None` for missing optional fields (especially dates and numbers). Do NOT invent data.
                        *   Be extremely thorough in extracting ALL billable items from the contract, as this is a critical part of the analysis.

                    **Output:** Provide the extracted data strictly conforming to the `models.Contract` Pydantic model structure, including nested `parties` and `billable_items`.
                    """

##subagent/invoice/invoice.py:
from google.adk.agents import Agent
from ai_contract_intelligence.sub_agents.invoice import invoice_prompt
invoice_agent = Agent(
    model='gemini-2.0-flash',
    name='invoice_agent',
    description="A system that identifies and extracts relevant information from invoice documents.",
    instruction=invoice_prompt.PROMPT,    
)

##subagent/invoice/prompt.py:
PROMPT = """
                    **Task:** Extract comprehensive information from the provided invoice text and structure format.

                    **Invoice Text:**
                    ```
                    ```

                    **Extraction Guidelines:**

                    1.  **Identify Core Fields:** Extract the following primary invoice details:
                        *   `invoice_number`: The unique ID of the invoice (e.g., "ACC-2023-0901").
                        *   `issue_date`: Date the invoice was created (Format: YYYY-MM-DD). If missing, use null.
                        *   `due_date`: Payment due date (Format: YYYY-MM-DD). If missing, use null.
                        *   `provider`: The name of the company SENDING the invoice (e.g., "Accenture").
                        *   `customer`: The name of the company RECEIVING the invoice (e.g., "State of Oklahoma Office of Management...").
                        *   `purchase_order_number`: PO number if mentioned.
                        *   `contract_id` or `contract_name`: Any reference to a master agreement or contract number (e.g., "AR3086", "NASPO ValuePoint..."). Extract the number if possible into `contract_id`, otherwise the name into `contract_name`.
                        *   `payment_terms`: Stated terms (e.g., "Net 30 days").
                        *   `notes`: Any general notes section.
                        *   `payment_date`: Date paid, if mentioned (Format: YYYY-MM-DD). Use null otherwise.

                    2.  **Currency Standardization:**
                        *   Identify the currency used (e.g., '$', 'USD').
                        *   Store the original symbol/code in `original_currency`.
                        *   Standardize the main `currency` field to its 3-letter ISO code (e.g., 'USD', 'EUR', 'GBP'). Assume 'USD' if '$' is used without other context.
                        *   All monetary fields (`discount_amount`, `tax_amount`, `invoice_subtotal`, `invoice_total`, `invoiced_rate`, `line_item_total`) should be represented in this standardized currency. Store original values if needed in `original_...` fields (though the primary instruction is to provide the standardized value).

                    3.  **Extract Billable Items:** Locate the table or list of services/products. For EACH item, extract:
                        *   `name`: Description of the item (e.g., "Cloud Architect Lead", "MDR, Minimum 250 Nodes").
                        *   `sku`: Item code, if available.
                        *   `unit_of_measure`: Unit (e.g., "hrs", "node", "Each").
                        *   `quantity`: Number of units billed (e.g., 80, 300).
                        *   `invoiced_rate`: Price per unit (standardized currency).
                        *   `line_item_total`: Total cost for that line (quantity * rate) (standardized currency).
                        *   `item_type`: Categorize if possible (e.g., "Service", "Bundle", "Labor"). Default to "Service".
                        *   `additional_notes`: Extract Scope of Work and agreed items.
                        *   Ensure these are populated in the `billable_items` list within the main Invoice object.

                    4.  **Calculate/Extract Totals:**
                        *   `discount_amount`: Total discount value (standardized currency).
                        *   `tax_amount`: Total tax value (standardized currency).
                        *   `invoice_subtotal`: Sum of all `line_item_total` values BEFORE tax/discount (standardized currency). Calculate if not explicitly stated.
                        *   `invoice_total`: The FINAL amount due (standardized currency). Should match the explicit total on the invoice.

                    5.  **Determine Status:**
                        *   Set the `status` field. Use 'paid' if payment date/confirmation exists. Use 'overdue' if the due date is past and no payment is indicated. Otherwise, default to 'pending' or 'unknown'.

                    6.  **Accuracy and Completeness:**
                        *   Extract values EXACTLY as they appear, before applying standardization logic where specified (e.g. original currency).
                        *   If a field is not present in the invoice, represent it as `null` or `None` in the final JSON structure, especially for dates and optional numbers. Do NOT invent data.

                    **Output:** Provide the extracted data strictly conforming to the `models.Invoice` Pydantic model structure, including the nested `billable_items`.
                    """

leakage:
(1)	Pricing Discrepancies: Identify differences in pricing for comparable products and services between invoices and contracts.
(2)	Duplication or Double Billed for Services: Detect instances where services are billed multiple times in the same invoice or across multiple invoices within a defined period.
(3)	Inflation Clause Violations: Check if invoiced rates comply with inflation clauses specified in the contract.
(4)	Change Order Discrepancies: Verify that invoiced amounts align with approved change orders or amendments.
(5)	Unapproved Fees: Detects any additional fees, taxes, or charges included on the invoice that are not part of the contracted pricing.
(6)	Discount Misapplication: Ensure that applicable quantity discounts or volume pricing tiers are correctly applied to the invoice.
(7)	Currency Conversion Errors: Identify discrepancies resulting from incorrect currency conversion rates or methods.
```
