#import "iosTestRunner.h"

#include "ios_test_runner.hpp"

#import "ZipArchive/ZipArchive.h"

#include <string>

@interface IosTestRunner ()

@property (nullable) TestRunner* runner;

@property (copy, nullable) NSString *resultPath;

@property (copy, nullable) NSString *metricPath;

@property BOOL testStatus;

@end

@implementation IosTestRunner

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.testStatus = false;
        self.runner = new TestRunner();
        NSString *path = nil;
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSArray *bundleContents = [fileManager contentsOfDirectoryAtPath: bundleRoot error: &error];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex: 0];
        
        for (uint32_t i = 0; i < bundleContents.count; i++) {
            NSString *dirName = [bundleContents objectAtIndex: i];
            if ([dirName isEqualToString:@"test-data"]) {
                NSString *destinationPath = [documentsDir stringByAppendingPathComponent: dirName];
                //Using NSFileManager we can perform many file system operations.
                BOOL success = [fileManager fileExistsAtPath: destinationPath];
                if (success) {
                    success = [fileManager removeItemAtPath:destinationPath error:NULL];
                }
                break;
            }
        }
        
        for (uint32_t i = 0; i < bundleContents.count; i++) {
            NSString *dirName = [bundleContents objectAtIndex: i];
            if ([dirName isEqualToString:@"test-data"]) {
                NSString *destinationPath = [documentsDir stringByAppendingPathComponent: dirName];
                BOOL success = [fileManager fileExistsAtPath: destinationPath];
                if (!success) {
                    NSString *copyDirPath  = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: dirName];

                    success = [fileManager copyItemAtPath: copyDirPath toPath: destinationPath error: &error];
              
                    if (!success){
                        NSAssert1(0, @"Failed to copy file '%@'.", [error localizedDescription]);
                        NSLog(@"Failed to copy %@ file, error %@", dirName, [error localizedDescription]);
                    }
                    else {
                        path = destinationPath;
                        NSLog(@"File copied %@ OK", dirName);
                    }
                }
                else {
                    NSLog(@"File exits %@, skip copy", dirName);
                }
                break;
            }
        }
        if (path) {
// //            NSString *styleManifestPath = [path stringByAppendingPathComponent:@"/next-ios-render-test-runner-style.json"];
// //            std::string styleManifest = std::string([styleManifestPath UTF8String]);
            
//             NSString *metricsManifestPath = [path stringByAppendingPathComponent:@"/next-ios-render-test-runner-metrics.json"];
//             std::string metricsManifest = std::string([metricsManifestPath UTF8String]);
            
//            self.testStatus = self.runner->startTest(styleManifest);
            std::string basePath = std::string([path UTF8String]);
            self.testStatus = self.runner->startTest(basePath);
            self.resultPath =  [path stringByAppendingPathComponent:@"/next-ios-render-test-runner-style.html"];

            NSString *docDirectory = [path stringByAppendingPathComponent:@"/next-ios-render-test-runner"];
            BOOL isDir = NO;
            NSArray *subpaths = [[NSArray alloc] init];;
            NSString *exportPath = docDirectory;
            if ([fileManager fileExistsAtPath:exportPath isDirectory:&isDir] && isDir){
                subpaths = [fileManager subpathsAtPath:exportPath];
            }
            else {
                 NSLog(@"Failed to find the archive sub directory");
            }
            NSString *archivePath = [docDirectory stringByAppendingString:@"/metrics.zip"];
            ZipArchive *archiver = [[ZipArchive alloc] init];
            if (archiver) {
                [archiver CreateZipFile2:archivePath];
                for(NSString *path in subpaths)
                {
                 NSString *longPath = [exportPath stringByAppendingPathComponent:path];
                 if([fileManager fileExistsAtPath:longPath isDirectory:&isDir] && !isDir)
                 {
                     [archiver addFileToZip:longPath newname:path];
                 }
                }

                if([archiver CloseZipFile2]) {
                 NSLog(@"Successfully archive all of the metrics into metrics.zip");
                 self.metricPath =  [path stringByAppendingPathComponent:@"/next-ios-render-test-runner/metrics.zip"];
                }
                else {
                 NSLog(@"Failed to archive metrics into metrics.zip");
                }
                
            } else {
                 NSLog(@"Failed to create archiver");
            }
            BOOL fileFound = [fileManager fileExistsAtPath: self.resultPath];
            if (!fileFound) {
                NSLog(@"Style test result file '%@' doese not exit ", self.resultPath);
            }
            self.testStatus &= fileFound;
        }

        delete self.runner;
        self.runner = nullptr;
    }
    return self;
}

- (NSString*) getResultPath {
   return self.resultPath;
}

- (NSString*) getMetricPath {
   return self.metricPath;
}

- (BOOL) getTestStatus {
   return self.testStatus;
}
@end
