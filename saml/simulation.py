import urllib.parse
import base64
import zlib
import sys
from lxml import etree

# ==============================
# INPUT
# ==============================

if len(sys.argv) != 2:
    print("Usage: python decode_saml.py <SAMLResponse>")
    sys.exit(1)

raw_input = sys.argv[1]   # masih URL-encoded
print("=== RAW URL-ENCODED INPUT ===")
print(raw_input)
print()

# ==============================
# URL Decode (setara req.query)
# ==============================

url_decoded = urllib.parse.unquote(raw_input)
print("=== AFTER URL DECODE ===")
print(url_decoded)
print()

# ==============================
# Base64 Decode
# ==============================

try:
    b64_decoded = base64.b64decode(url_decoded)
except Exception as e:
    print("Base64 decode error:", e)
    sys.exit(1)

print("=== AFTER BASE64 DECODE (bytes) ===")
print(b64_decoded)
print()

# ==============================
# zlib.inflateRawSync (wbits=-15)
# ==============================

try:
    xml_bytes = zlib.decompress(b64_decoded, -15)
except Exception as e:
    print("zlib raw inflate error:", e)
    sys.exit(1)

xmlString = xml_bytes.decode()
print("=== XML STRING (xmlString) ===")
print(xmlString)
print()

# ==============================
# DOMParser.parseFromString
# ==============================

try:
    xmlDoc = etree.fromstring(xml_bytes)
except Exception as e:
    print("XML parse error:", e)
    sys.exit(1)

print("=== PARSED XML ROOT TAG ===")
print(xmlDoc.tag)
print()

print("=== PRETTY XML (xmlDoc) ===")
print(etree.tostring(xmlDoc, pretty_print=True).decode())
print()

# ==============================
# Extract username (textContent)
# ==============================

xpath_expr = './/Attribute[@Name="http://schemas.goauthentik.io/2021/02/saml/username"]/AttributeValue'

vals = xmlDoc.xpath(xpath_expr)

if vals:
    username = vals[0].text
else:
    username = None

print("=== EXTRACTED USERNAME ===")
print(username)
print()

# ==============================
# Simulate Node.js behavior
# ==============================

if username == "akadmin":
    print("[SIMULATION] You would get FLAG here.")
else:
    print(f"[SIMULATION] Hello {username}. You are not authorized.")
