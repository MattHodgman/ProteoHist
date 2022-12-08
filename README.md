# ProteoHist
An AI method for predicting spatial tumor protein expression from H&amp;E histopathology whole-slide images.

## Data Aquisition
Download CPTAC endometrial cancer whole-slide images from [here](https://wiki.cancerimagingarchive.net/pages/viewpage.action?pageId=33948263) and protein expression data from [this paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7233456/). We split the data into three groups
- slides of normal tissue ("normal")
- slides of of at least 90% tumor tissue ("tumor")
- slides with both tumor and normal tissue ("both")

## Decide Protein Expression Targets
Decide which proteins you would like to predict. We recommend those that are both significantly differentially expressed between tumor and normal and have a large effect size. Additionally, it would be impactful if the proteins have a known drug interaction.

## Metadata
Explore the associated metadata to identify potential biases or batch effects.

## Directory Organization
We create a `Data` folder for all data. Within it are `Metadata`, `Images`, and `ExpressionData` folders. Within `Images` are the directories `raw_images`, `heat_maps`, and `clam_output`. Both the `raw_images` and `clam_output` folders have three subfolders: `both`, `normal`, and `tumor`. CLAM will create subdirectories under those three directories.

## Preprocess images
1. Use CLAM to segment the whole-slide images and extract patch coordinates.
2. Identify and remove any images that were not segmented correctly.
3. Use CLAM (ResNet50 trained on ImageNet) to extract features for each patch.

## Run Multioutput regression
1. Split cases and controls, by patient, into training and validation sets.
2. Train and validate linear regression model with patch features as input and protein expression as output.
3. Test model on test set that contains both tumor and normal tissue.

## Create Heat Maps
Stitch patches back together to recreate image of tissue slide and color each patch by protein expression.
