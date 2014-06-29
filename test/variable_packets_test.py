
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
    def test_framegrab_contains_framegrab_data(self):
        output = tshark(
            captureFile="resources/1.0_front_good_backlight_framegrab.pcapng", 
            filter_="0dbcomms.sync == 0xCC",
            fields=["0dbcomms.sync", "0dbcomms.port", "0dbcomms.command"])
        self.assertGreater(len(output.splitlines()), 0)