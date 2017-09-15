import unittest
import custom_malis
import numpy as np

# hacky pymalis import
import sys
sys.path.append('/groups/saalfeld/home/papec/Work/my_projects/nnets')
# get pymalis for comparison tests
try:
    import pymalis
    have_pymalis = True
    print("Tests with pymalis")
except ImportError:
    have_pymalis = False
    print("Tests without pymalis")


class TestMalis(unittest.TestCase):

    def generate_test_data(self, dim, aff_channels):
        shape = tuple(10 if (d == 0 and dim == 3) else 64 for d in range(dim))
        affShape = (aff_channels,) + shape
        affs = np.random.random_sample(size=affShape).astype('float32')
        seg = np.zeros(shape, dtype='uint32')
        current_label = 0
        for ii in range(seg.size):
            index  = np.unravel_index(ii, shape)
            seg[index] = current_label
            if np.random.rand() > .8:
                current_label += 1
        return affs, seg


    def test_single_malis(self):
        for dim in (2, 3):
            affs, seg = self.generate_test_data(dim, dim)
            for pos in (False, True):
                grads = custom_malis.malis(affs, seg, pos)
                self.assertTrue(np.isfinite(grads).all())


    def test_constrained_malis(self):
        for dim in (2, 3):
            affs, seg = self.generate_test_data(dim, dim)
            grads = custom_malis.constrained_malis(affs, seg)
            self.assertTrue(np.isfinite(grads).all())
            if dim == 3 and have_pymalis:
                pymalis_pos, pymalis_neg = pymalis.malis(affs, seg.astype('int64'))
                pymalis_grads = - (pymalis_pos + pymalis_neg) / 2.
                assert pymalis_grads.shape == grads.shape
                diff = np.isclose(grads, pymalis_grads)
                print(np.sum(diff), '/')
                print(grads.size)
                self.assertTrue(diff.all())


    def test_custom_constrained_malis(self):
        dim = 3
        aff_channels = 9
        affs, seg = self.generate_test_data(dim, aff_channels)
        ranges = [-1, -1, -1, -2, -4, -4, -3, -8, -8]
        axes  = [ 0,  1,  2,  0,  1,  2,  0,  1,  2]
        grads = custom_malis.constrained_malis_custom_nh(affs, seg, ranges, axes)
        self.assertTrue(np.isfinite(grads).all())


if  __name__ == '__main__':
    unittest.main()
