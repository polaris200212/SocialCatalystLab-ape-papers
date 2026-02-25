"""Fetch Décret 2023-822 from Légifrance API to extract TLV expansion commune list."""
import requests, os, json

client_id = os.environ.get('PISTE_OAUTH_KEY', '')
client_secret = os.environ.get('PISTE_OAUTH_CLIENTID', '')

if not client_id or not client_secret:
    print('No PISTE credentials')
    exit(1)

# Get token
resp = requests.post('https://oauth.piste.gouv.fr/api/oauth/token',
    data={
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret,
        'scope': 'openid'
    })

if resp.status_code != 200:
    print(f'Auth failed: {resp.status_code}')
    print(resp.text[:500])
    exit(1)

token = resp.json()['access_token']
print('Auth OK')

headers = {'Authorization': f'Bearer {token}'}

# Try direct JORF consult for the decree
jorf_resp = requests.post(
    'https://api.piste.gouv.fr/dila/legifrance-beta/lf-engine-app/consult/jorf',
    headers=headers,
    json={'textId': 'JORFTEXT000047984658'}
)
print(f'JORF status: {jorf_resp.status_code}')

if jorf_resp.status_code == 200:
    jorf = jorf_resp.json()
    with open('../data/decree_2023_822.json', 'w') as f:
        json.dump(jorf, f, ensure_ascii=False)
    print(f'Top-level keys: {list(jorf.keys())}')
    # Navigate structure
    if 'text' in jorf:
        text = jorf['text']
        print(f'text keys: {list(text.keys()) if isinstance(text, dict) else type(text)}')
    print('Saved to data/decree_2023_822.json')
else:
    print(f'Error: {jorf_resp.text[:500]}')

    # Try alternative: consult/code article
    code_resp = requests.post(
        'https://api.piste.gouv.fr/dila/legifrance-beta/lf-engine-app/consult/code/article',
        headers=headers,
        json={'id': 'LEGIARTI000047984810'}
    )
    print(f'Code article status: {code_resp.status_code}')
    if code_resp.status_code == 200:
        with open('../data/decree_article.json', 'w') as f:
            json.dump(code_resp.json(), f, ensure_ascii=False)
        print('Saved article to data/decree_article.json')
