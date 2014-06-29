
import unittest
import subprocess
from itertools import chain

def tshark(captureFile, fields=None, filter_=None):
    argCaptureFile = ["-r", captureFile]
    if fields:
        field_args = [["-e", f] for f in fields]
        argFields = ["-T", "fields"] + list(chain(*field_args))
    if filter_:
        argFilter = ["-Y", filter_]
    args = ["c:/Program Files/Wireshark/tshark.exe"] +\
        argFilter +\
        argCaptureFile +\
        argFields

    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (out, err) = p.communicate()
    if err:
        raise StandardError(err)
    return out

class TestVariablePackets(unittest.TestCase):
    def test_demo_protocol_contains_short_messages(self):
        output = tshark(
            captureFile="resources/dumpfile.pcapng", 
            filter_="demo.type == 0x01",
            fields=["demo.type", "demo.checksum", "demo.command", "demo.payload"])
        self.assertGreater(len(output.splitlines()), 0)