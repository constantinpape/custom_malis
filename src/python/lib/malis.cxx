#include <pybind11/pybind11.h>

namespace py = pybind11;


namespace custom_malis {
    void exportMalisLoss(py::module &);
}


PYBIND11_PLUGIN(_custom_malis) {

    py::module malisModule("_custom_malis", "C++ implementation of malis loss");

    using namespace custom_malis;

    exportMalisLoss(malisModule);

    return malisModule.ptr();
}
