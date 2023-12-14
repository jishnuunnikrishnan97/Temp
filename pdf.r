import fitz

def extract_images_from_pdf(pdf_path, image_folder):
    doc = fitz.open(pdf_path)
    
    for page_number in range(doc.page_count):
        page = doc[page_number]
        images = page.get_images(full=True)
        
        for img_index, img_info in enumerate(images):
            img_index += 1
            base_image = doc.extract_image(img_info[0])
            image_bytes = base_image["image"]
            
            image_filename = f"{image_folder}/page{page_number + 1}_img{img_index}.png"
            
            with open(image_filename, "wb") as image_file:
                image_file.write(image_bytes)

    doc.close()

# Example usage:
pdf_path = "your_pdf.pdf"
output_folder = "output_images"
extract_images_from_pdf(pdf_path, output_folder)
