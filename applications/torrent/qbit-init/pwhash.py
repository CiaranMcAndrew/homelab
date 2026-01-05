#!/usr/bin/env python
#
# Generates a PBKDF2 hash for qBittorrent WebUI password. This is useful for setting the password in the config file.
#
# Usage: python pwhash.py <password>
#
# Adopted from: https://gist.github.com/hastinbe/8b8d247f17481cfc262a98d661bc0fd5
# Beau Hastings (https://github.com/hastinbe)
# License: GPLv2

import hashlib
import os
import sys
import base64

def generate_qbittorrent_hash(password: str = None) -> str:
    # Validate input
    if password is None:
        if len(sys.argv) != 2:
            print("Usage: python pwhash.py <password>")
            sys.exit(1)
        password = sys.argv[1]

    # Generate a random salt
    salt = os.urandom(16)
    iterations = 40      # Number of iterations
    algorithm = 'sha512' # Hashing algorithm

    # Generate PBKDF2 hash
    dk = hashlib.pbkdf2_hmac(algorithm, password.encode(), salt, iterations)

    # Base64 encode the salt and hash
    encoded_salt = base64.b64encode(salt).decode()
    encoded_hash = base64.b64encode(dk).decode()

    # Format for qBittorrent
    qbittorrent_hash = f'@ByteArray({encoded_salt}:{encoded_hash})'

    return qbittorrent_hash

if __name__ == "__main__":
    password = sys.argv[1] if len(sys.argv) == 2 else None
    qbittorrent_hash = generate_qbittorrent_hash(password)
    print(qbittorrent_hash)