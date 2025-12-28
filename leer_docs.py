import zipfile
import re
import xml.etree.ElementTree as ET
import os

def read_docx(file_path):
    try:
        with zipfile.ZipFile(file_path) as docx:
            xml_content = docx.read('word/document.xml')
            tree = ET.fromstring(xml_content)
            paragraphs = []
            for p in tree.iter():
                if p.tag.endswith('}p'):
                    texts = [node.text for node in p.iter() if node.tag.endswith('}t') and node.text]
                    if texts:
                        paragraphs.append(''.join(texts))
            return '\n'.join(paragraphs)
    except Exception as e:
        return f"Error leyendo {file_path}: {str(e)}"

def extract_urls(text):
    url_pattern = re.compile(r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+[/\w\.-]*')
    return url_pattern.findall(text)

files = ["Guía Instalación ROMs GSI Redmi Note 11.docx", "Informe Actualizado_ GSI ROMs para Redmi Note 11 Pro (viva).docx"]
full_content = ""
all_urls = []

for f in files:
    print(f"Procesando {f}...")
    content = read_docx(f)
    urls = extract_urls(content)
    
    full_content += f"\n\n=== CONTENIDO DE: {f} ===\n\n"
    full_content += content
    
    if urls:
        all_urls.extend(urls)
        print(f"Encontradas {len(urls)} URLs en {f}")

# Guardar contenido completo
with open("informacion_extraida.txt", "w", encoding="utf-8") as f:
    f.write(full_content)

# Guardar URLs encontradas
with open("lista_urls.txt", "w", encoding="utf-8") as f:
    for url in all_urls:
        f.write(url + "\n")

print("Proceso completado. Revisa informacion_extraida.txt y lista_urls.txt")
