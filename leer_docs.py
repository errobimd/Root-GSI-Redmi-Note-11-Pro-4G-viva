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

files = ["Guía Instalación ROMs GSI Redmi Note 11.docx", "Informe Actualizado_ GSI ROMs para Redmi Note 11 Pro (viva).docx"]
for f in files:
    print(f"--- CONTENIDO DE: {f} ---")
    print(read_docx(f))
    print("\n" + "="*50 + "\n")
