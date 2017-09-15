#include "gtest/gtest.h"
#include "custom_malis/custom_malis.hxx"
#include <random>

namespace custom_malis {

    void randomAffinities(nifty::marray::View<float> & view) {
        std::default_random_engine gen;
        std::uniform_real_distribution<float> distr(0., 1.);
        auto draw = std::bind(distr, gen);
        for(auto it = view.begin(); it != view.end(); ++it) {
            *it = draw();
        }
    }

    void randomSegmentation(nifty::marray::View<uint32_t> & view) {
        std::default_random_engine gen;
        std::uniform_real_distribution<float> distr(0., 1.);
        auto draw = std::bind(distr, gen);

        uint32_t currentLabel = 0;
        for(auto it = view.begin(); it != view.end(); ++it) {
            *it = currentLabel;
            if(draw() > .8) {
                ++currentLabel;
            }
        }
    }

    TEST(MalisTest, testSingleMalis2D) {

        std::vector<size_t> shapeSeg({256, 256});
        std::vector<size_t> shapeAff({2, 256, 256});

        nifty::marray::Marray<float> affinities(shapeAff.begin(), shapeAff.end());
        nifty::marray::Marray<uint32_t> segmentation(shapeSeg.begin(), shapeSeg.end());

        nifty::marray::Marray<float> gradients(shapeAff.begin(), shapeAff.end());
        std::vector<int> ranges = {-1, -1};
        std::vector<int> axes = {0, 1};

        std::vector<bool> poss = {false, true};
        float loss, err, rand;
        for(auto pos : poss) {
            compute_malis_gradient<2>(affinities, groundtruth, ranges, axes, pos, gradients, loss, err, rand);
            for(auto it = gradients.begin(); it != gradients.end(); ++it) {
                ASSERT_TRUE(std::isfinite(*it));
            }
        }

    }

}
