import os
import unittest
import utils.core.file_processor as fp

class TestCoreUtilLoadHashes(unittest.TestCase):
    def test_hash_loaded(self):
        self.assertNotEqual(len(fp.MALWARE_HASHES), 0)

    def test_hash_check(self):
        self.assertTrue(fp._checkMalwareBySha256('6d15869a35a4289c3214c3f703fb4d5feb80eb740def6f982ff6cc868e9e58f8'))

    def test_get_decomp(self):
        bin_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'helloworld')
        with open(bin_path, 'rb') as file:
            self.assertIsNotNone(fp._getDecompilation(file.read()))

if __name__ == '__main__':
    unittest.main()
