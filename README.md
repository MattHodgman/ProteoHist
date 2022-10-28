# ProteoPath
An AI method for predicting tumor protein expression from H&amp;E histopathology whole-slide images.

### Data Aquisition
Download whole-slide images and protein expression data from CPTAC. We split the data into three groups
- slides of normal tissue (controls)
- slides of of at least 90% tumor tissue (cases)
- slides with both tumor and normal tissue (test set)

### Metadata
Explore the associated metadata to identify potential biases or batch effects.

### Directory Organization
Split case and control images into separate directories.

### Environment Setup
Clone CLAM and set up conda environment.

### Preprocess images
1. Use CLAM to segment the whole-slide images and extract patch coordinates.
2. Identify and remove any images that were not segmented correctly.
3. Use CLAM (ResNet50 trained on ImageNet) to extract features for each patch.

### Run Multiclass Classification/Prediction Multi-Layer Perceptron (MLP)
1. Split cases and controls, by patient, into training and validation sets.
2. Train and validate MLP with patch features as input and protein expression as output.
3. Test MLP on test set that contains both tumor and normal tissue.

### Create Heat Maps
Stitch patches back together to recreate image of tissue slide and color each patch by protein expression.
