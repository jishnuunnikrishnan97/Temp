```
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
 


```
