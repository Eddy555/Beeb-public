#!/usr/bin/env python3
"""Check Beeb's unsigned tvOS release without extracting or printing secrets."""
import argparse
from pathlib import PurePosixPath
import plistlib
import re
import struct
import sys
import zipfile


def inspect(path):
    failures = []
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
        apps = {name.split('/')[1] for name in names if name.startswith('Payload/') and len(name.split('/')) >= 3 and name.split('/')[1].endswith('.app')}
        if len(apps) != 1:
            return ['Expected exactly one app beneath Payload/.']
        prefix = 'Payload/' + next(iter(apps)) + '/'
        for item in archive.infolist():
            name = item.filename
            parts = PurePosixPath(name).parts
            if name.startswith('/') or '..' in parts:
                failures.append('Unsafe archive path.')
            if '_CodeSignature' in parts or name.endswith(('.mobileprovision', '.provisionprofile', '.p12', '.pfx', '.pem', '.key', '.dSYM')) or '__MACOSX' in parts:
                failures.append('Signing material or platform metadata present.')
            data = archive.read(item)
            patterns = [rb'/(?:Users|home)/[A-Za-z0-9_.-]+/',
                        rb'-----BEGIN (?:RSA |EC |ENCRYPTED )?PRIVATE KEY-----',
                        rb'Apple Development:', rb'iPhone Developer:']
            if any(re.search(pattern, data) for pattern in patterns):
                failures.append('Personal path, private key or developer identity marker present.')
        info = plistlib.loads(archive.read(prefix + 'Info.plist'))
        if info.get('CFBundleSupportedPlatforms') != ['AppleTVOS']:
            failures.append('App is not built for physical tvOS devices.')
        if info.get('CFBundleIdentifier') != 'org.beebplayer.Beeb':
            failures.append('App does not have the public template bundle identifier.')
        data = archive.read(prefix + info['CFBundleExecutable'])
        if data[:4] != b'\xcf\xfa\xed\xfe' or len(data) < 32:
            failures.append('Expected a 64-bit little-endian device executable.')
        else:
            if struct.unpack_from('<I', data, 4)[0] != 0x0100000c:
                failures.append('Expected arm64 architecture.')
            offset = 32
            for _ in range(struct.unpack_from('<I', data, 16)[0]):
                command, size = struct.unpack_from('<II', data, offset)
                if size < 8 or offset + size > len(data):
                    failures.append('Invalid executable load command.')
                    break
                if command == 0x1d:
                    failures.append('Executable still contains a code signature.')
                if command == 0x2c and struct.unpack_from('<I', data, offset + 16)[0] != 0:
                    failures.append('Executable is encrypted.')
                offset += size
        if archive.testzip() is not None:
            failures.append('Archive integrity check failed.')
    return sorted(set(failures))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('ipa')
    args = parser.parse_args()
    try:
        failures = inspect(args.ipa)
    except (OSError, ValueError, KeyError, zipfile.BadZipFile, struct.error):
        failures = ['Archive is missing required data or is malformed.']
    for failure in failures:
        print('FAIL: ' + failure)
    if failures:
        return 1
    print('PASS: public-template arm64 tvOS app; no code signature/profile or detected personal-path/private-key markers. This is not an exhaustive privacy audit.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
