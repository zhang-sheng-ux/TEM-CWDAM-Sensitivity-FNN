# TEM-CWDAM-Sensitivity-FNN

Parameter sensitivity analysis and rapid neural network prediction for transient electromagnetic (TEM) responses in core-wall dams.

---

## Repository Contents

| File Name                | Description (Function)                                                                                                                                                                               |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| untitled\_sobal2\_2\_.  m  | Grouped time-varying permutation sensitivity analysis for geometric and resistivity parameters, with repeated runs and smoothing.   Saves result matrices for further use.                               |
| untitled\_sobal2\_2\_1.  m | Visualization of smoothed, time-varying permutation sensitivity (with ±1σ confidence bands) for geometric and resistivity groups, on a log-time axis.   Publication-ready.                               |
| untitled\_sobal2\_3.  m    | Pairwise (interaction) permutation sensitivity analysis across multiple time intervals, with repeated runs, progress display, and output of lower-triangular sensitivity matrices.                     |
| untitled\_sobal2\_4.  m    | Visualization and beautification of lower-triangular pairwise permutation sensitivity heatmaps, with gray fill and special labels for low-sensitivity values.                                          |
| untitled\_sobal2\_5.  m    | Pairwise permutation sensitivity analysis for all parameters over the entire time window (no segmentation), including heatmap output and result saving.                                                |
| untitled\_sobal2\_6.  m    | Visualization of the lower-triangular pairwise permutation sensitivity heatmap for the full time window, with formatting for publication-quality figures and gray fill.                                |
| untitled\_sobal3\_2.  m    | Feedforward neural network (FNN) modeling and rapid prediction for TEM response curves under multi-parameter conditions, including training, test evaluation, and prediction for new parameter sets.   |
| untitled\_sobal3\_5.  m    | Systematic comparison of neural network activation functions and algorithms (2 layers, 20 neurons each) for TEM prediction;   outputs MSE, R², and training time to a CSV file.                          |

---

## How to use

1.   **Preparation:**
Place all files in one directory and make sure you have the input data file `normalized_data.  mat` (see script comments for structure requirements).

2.   **Sensitivity analysis:**

* Run `untitled_sobal2_2_.  m` for grouped main effect permutation sensitivity (geometry/resistivity).
* Run `untitled_sobal2_2_1.  m` for time-varying sensitivity plotting with confidence bands.
* Run `untitled_sobal2_3.  m` and `untitled_sobal2_4.  m` for pairwise (interaction) sensitivity analysis and heatmap visualization across time intervals.
* Run `untitled_sobal2_5.  m` and `untitled_sobal2_6.  m` for all-window (non-segmented) pairwise sensitivity analysis and plotting.

3.   **Neural network modeling:**

* Run `untitled_sobal3_2.  m` for FNN training, test, and prediction on new samples.
* Run `untitled_sobal3_5.  m` to compare different activation functions and training algorithms, with results saved to CSV.

---

## Requirements

* MATLAB R2019a or newer
* Statistics and Machine Learning Toolbox
* Neural Network Toolbox

---

## Data

* The file `normalized_data.  mat` is required but not provided here (see code comments for the required structure).
* Result `.  mat` files and CSV outputs are produced by running the scripts.

---

## Citation



## License


---

## Contact
Shenghang Zhang
National Key Laboratory of Water Disaster Prevention, NHRI, Nanjing, China
Email: [sxzhang@nhri.cn]

Lei Tang (Corresponding Author)
National Key Laboratory of Water Disaster Prevention, NHRI, Nanjing, China
Email: [ltang@nhri.cn]
