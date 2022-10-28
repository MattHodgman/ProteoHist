# ProteoPath
An AI method for predicting tumor protein expression from H&amp;E histopathology whole-slide images.

## Data Aquisition
Download whole-slide images and protein expression data from CPTAC. We split the data into three groups
- slides of normal tissue (controls)
- slides of of at least 90% tumor tissue (cases)
- slides with both tumor and normal tissue (test set)

## Decide Protein Expression Targets
Decide which proteins you would like to predict. We recommend those that are both significantly differentially expressed between cases and control and have a large effect size. Additionally, it would be impactful if the proteins have a known drug interaction. Next, decide if you want to bin protein expression into low, medium, and high expression values or use a regression model to predict expression between 0-1.

## Metadata
Explore the associated metadata to identify potential biases or batch effects.

## Directory Organization
Split case and control images into separate directories.

## Environment Setup
Clone CLAM and set up conda environment.

## Preprocess images
1. Use CLAM to segment the whole-slide images and extract patch coordinates.
2. Identify and remove any images that were not segmented correctly.
3. Use CLAM (ResNet50 trained on ImageNet) to extract features for each patch.

## Run Multiclass Classification/Prediction Multi-Layer Perceptron (MLP)
1. Split cases and controls, by patient, into training and validation sets.
2. Train and validate MLP with patch features as input and protein expression as output.
3. Test MLP on test set that contains both tumor and normal tissue.

## Create Heat Maps
Stitch patches back together to recreate image of tissue slide and color each patch by protein expression.