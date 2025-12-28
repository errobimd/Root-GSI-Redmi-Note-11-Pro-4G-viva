import requests
import json

def check_urls():
    try:
        with open('lista_urls.txt', 'r') as f:
            raw_urls = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print("Archivo lista_urls.txt no encontrado.")
        return

    results = []
    print(f"Iniciando verificación de {len(raw_urls)} enlaces...")
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }

    for url in raw_urls:
        if not url.startswith('http'):
            continue
            
        category = 'General'
        if 'github.com' in url or 'gist.github.com' in url: category = 'Desarrollo/GitHub'
        elif 'sourceforge.net' in url: category = 'Descargas/Herramientas'
        elif 'youtube.com' in url: category = 'Tutorial/Video'
        elif 'reddit.com' in url: category = 'Comunidad/Reddit'
        elif 'xiaomirom.com' in url or 'mi.com' in url: category = 'Firmware/Xiaomi'
        
        status_info = {'url': url, 'category': category}
        try:
            # Intentar HEAD primero (más rápido)
            r = requests.head(url, timeout=8, allow_redirects=True, headers=headers)
            # Muchos sitios devuelven 403/405 a HEAD pero 200 a GET
            if r.status_code >= 400:
                 r = requests.get(url, timeout=8, stream=True, headers=headers)
            
            status_info['status'] = r.status_code
            status_info['accessible'] = r.status_code < 400
        except Exception as e:
            status_info['status'] = 'Error'
            status_info['accessible'] = False
            status_info['msg'] = str(e)[:50]
        
        results.append(status_info)
        print(f"Checked: {url[:50]}... -> {status_info['status']}")

    with open('REPORTE_URLS.md', 'w', encoding='utf-8') as f:
        f.write('# Reporte de Auditoría de Enlaces Externos\n\n')
        f.write('Este reporte detalla el estado actual de los enlaces extraídos de la documentación oficial y técnica para el Redmi Note 11 Pro 4G (viva).\n\n')
        f.write('| Categoría | Estado | URL | Notas |\n')
        f.write('| :--- | :--- | :--- | :--- |\n')
        for res in results:
            status_icon = '✅' if res['accessible'] else '❌'
            note = ''
            
            # Casos especiales
            if 'youtube.com/watch' in res['url'] and 'v=' not in res['url']:
                note = '⚠️ URL incompleta (sin ID de video)'
                status_icon = '⚠️'
            elif res['status'] == 'Error':
                note = 'Desconectado / Timeout'
            elif not res['accessible']:
                note = 'Enlace roto o restringido'
            
            f.write(f'| {res["category"]} | {status_icon} ({res["status"]}) | [{res["url"]}]({res["url"]}) | {note} |\n')

    print('\n¡Auditoría completada!')
    print('Archivo generado: REPORTE_URLS.md')

if __name__ == "__main__":
    check_urls()
