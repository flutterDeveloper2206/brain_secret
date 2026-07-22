#import "OpenCVWrapper.h"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

@implementation OpenCVWrapper

+ (cv::Mat)preprocess:(cv::Mat)mat {
  Mat gray;
  if (mat.channels() == 4) {
    cvtColor(mat, gray, COLOR_RGBA2GRAY);
  } else if (mat.channels() == 3) {
    cvtColor(mat, gray, COLOR_RGB2GRAY);
  } else {
    gray = mat.clone();
  }

  // 2. Bilateral Filter
  Mat smoothed;
  bilateralFilter(gray, smoothed, 9, 75.0, 75.0);

  // 3. CLAHE
  Ptr<CLAHE> clahe = createCLAHE(6.0, Size(8, 8));
  Mat enhanced;
  clahe->apply(smoothed, enhanced);

  // 4. Adaptive Threshold - WHITE ridges on BLACK background
  Mat binary;
  adaptiveThreshold(enhanced, binary, 255.0, ADAPTIVE_THRESH_GAUSSIAN_C,
                    THRESH_BINARY_INV, 51, 6.0);

  // 5. Morphological Smoothing
  Mat kernel = getStructuringElement(MORPH_ELLIPSE, Size(3, 3));
  morphologyEx(binary, binary, MORPH_CLOSE, kernel);

  // 6. Median Blur
  medianBlur(binary, binary, 3);

  // 7. Area Filtering
  Mat labels, stats, centroids;
  int numLabels =
      connectedComponentsWithStats(binary, labels, stats, centroids);

  Mat cleaned = Mat::zeros(binary.size(), CV_8UC1);
  for (int i = 1; i < numLabels; i++) {
    int area = stats.at<int>(i, CC_STAT_AREA);
    int width = stats.at<int>(i, CC_STAT_WIDTH);
    int height = stats.at<int>(i, CC_STAT_HEIGHT);

    if (area > 150 || (width > 20 || height > 20)) {
      Mat mask = (labels == i);
      bitwise_or(cleaned, mask, cleaned);
    }
  }

  return cleaned;
}

+ (cv::Mat)skeletonize:(cv::Mat)input {
  Mat skel = Mat::zeros(input.size(), CV_8UC1);
  Mat temp, eroded;
  Mat element = getStructuringElement(MORPH_CROSS, Size(3, 3));
  bool done = false;

  Mat copy = input.clone();

  while (!done) {
    erode(copy, eroded, element);
    dilate(eroded, temp, element);
    subtract(copy, temp, temp);
    bitwise_or(skel, temp, skel);
    eroded.copyTo(copy);

    if (countNonZero(copy) == 0)
      done = true;
  }
  return skel;
}

+ (NSData *)processImage:(NSString *)imagePath {
  UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
  if (!image)
    return nil;

  Mat mat;
  UIImageToMat(image, mat);

  Mat cleaned = [self preprocess:mat];

  // Invert to show BLACK RIDGES on WHITE BACKGROUND (like the original photo)
  Mat inverted;
  bitwise_not(cleaned, inverted);

  UIImage *resultImage = MatToUIImage(inverted);
  return UIImagePNGRepresentation(resultImage);
}

+ (int)countRidges:(NSString *)imagePath
             coreX:(double)coreX
             coreY:(double)coreY
              endX:(double)endX
              endY:(double)endY {
  UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
  if (!image)
    return 0;

  Mat mat;
  UIImageToMat(image, mat);

  Mat cleaned = [self preprocess:mat];
  Mat skel = [self skeletonize:cleaned];

  int count = 0;
  double dx = endX - coreX;
  double dy = endY - coreY;
  double length = sqrt(dx * dx + dy * dy);
  if (length < 2.0)
    return 0;

  // High density sampling (0.2px)
  int steps = (int)(length * 5);
  bool ridgeState = false;
  int ridgePixels = 0;

  // Skip small area around core
  double stepSize = length / steps;
  int skipSteps = (int)(5.0 / stepSize);
  if (skipSteps > steps / 4)
    skipSteps = steps / 4;

  for (int i = 0; i < steps; i++) {
    double t = (double)i / steps;
    int px = (int)(coreX + t * dx);
    int py = (int)(coreY + t * dy);

    if (px < 0 || px >= skel.cols || py < 0 || py >= skel.rows)
      continue;

    uchar value = skel.at<uchar>(py, px);
    bool isRidge = value > 127;

    if (i > skipSteps) {
      if (isRidge && !ridgeState) {
        ridgeState = true;
        ridgePixels = 1;
      } else if (isRidge && ridgeState) {
        ridgePixels++;
      } else if (!isRidge && ridgeState) {
        if (ridgePixels >= 3) {
          count++;
        }
        ridgeState = false;
        ridgePixels = 0;
      }
    }
  }

  if (ridgeState && ridgePixels >= 3) {
    count++;
  }

  return count;
}

@end
