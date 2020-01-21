#include "ios_test_runner.hpp"

#include <mbgl/render_test.hpp>

#include <mbgl/util/logging.hpp>

#include <vector>

#define EXPORT __attribute__((visibility("default")))

EXPORT
bool TestRunner::startTest(const std::string& manifestBasePath) {

    auto runTestWithManifest = [](const std::string& manifest) -> bool {
        std::vector<std::string> arguments = {"mbgl-render-test-runner", "-p", manifest, "-u", "rebaseline"};
        std::vector<char*> argv;
        for (const auto& arg : arguments) {
            argv.push_back(const_cast<char*>(arg.data()));
        }
        argv.push_back(nullptr);

        int finishedTestCount = 0;
        std::function<void()> testStatus = [&]() {
            mbgl::Log::Info(mbgl::Event::General, "Current finished tests number is '%d' ", ++finishedTestCount);
        };
        mbgl::Log::Info(mbgl::Event::General, "Start running RenderTestRunner with manifest: '%s'", manifest.c_str());

        auto result = mbgl::runRenderTests(static_cast<int>(argv.size() - 1), argv.data(), testStatus) == 0;
        mbgl::Log::Info(mbgl::Event::General, "End running RenderTestRunner with manifest: '%s'", manifest.c_str());
        return result;
    };

    auto ret = false;
    try {
        ret = runTestWithManifest(manifestBasePath + "/next-ios-render-test-runner-style.json");
        ret = runTestWithManifest(manifestBasePath + "/next-ios-render-test-runner-metrics.json") && ret;
    } catch (...) {
        mbgl::Log::Info(mbgl::Event::General, "iOS RenderTestRunner Failed to run all of the tests");
    }
    mbgl::Log::Info(mbgl::Event::General, "All tests are finished!");
    return ret;
}
