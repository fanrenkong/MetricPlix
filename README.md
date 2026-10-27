<p align="center">
  <img src="resources/metricplix-logo.png" alt="MetricPlix Logo" width="120">
</p>

<h1 align="center">MetricPlix</h1>

<p align="center"><em>Metrics. Plots. Mix.</em></p>

<p align="center"><strong>English</strong> | <a href="README.zh-CN.md">简体中文</a></p>

MetricPlix is an experiment result analysis tool built with MATLAB App Designer. It supports comparisons across multiple algorithms, tasks, and independent runs. The application reads MAT files organized in a standard directory structure, computes built-in or custom metrics, performs statistical tests, and exports LaTeX tables for research papers.

![Main interface](docs/images/main.png)

## Features

- **Import experiment results**: Read results organized by algorithm, task, and run number.
- **Metric analysis**: A runtime metric is included as an example. Add custom metrics to suit your experiments.
- **Result summaries**: Display the mean ± standard deviation for each algorithm on each task, with the best result highlighted in bold.
- **Statistical tests**: Perform Wilcoxon rank-sum tests, summarize `+/=/-` counts across tasks, and calculate Friedman mean ranks.
- **Reusable configurations**: Save data paths, algorithm and task ordering, the selected metric, and the number of runs for later use.
- **LaTeX export**: Export `.tex` files containing significance symbols, bold best results, and rankings.
- **Custom metrics**: Extend the application through a consistent function interface without modifying the main program.

The Graph tab currently displays **Coming Soon~**. Plotting is not yet available.

## Requirements

- MATLAB. The current project has been verified with **MATLAB R2024a**.
- Statistics and Machine Learning Toolbox: Required for `ranksum` and `friedman`, including when comparing algorithms using only the runtime metric.

To launch the application:

1. Download or clone this repository.
2. Set the MATLAB current folder to the project root.
3. Run the following commands:

```matlab
% The current folder should be the MetricPlix project root.
addpath(pwd);
metricPlix;
```

Alternatively, open `metricPlix.mlapp` in App Designer and click Run. Add the project root to the MATLAB search path before launching the application.

## Data Directory Structure

Organize your experiment results as follows:

```text
results/                       # Select this folder when importing
├── AlgorithmA/                # Algorithm name: a table column
│   ├── Task1/                 # Task or dataset name: a table row
│   │   ├── 1.mat              # Results from run 1
│   │   ├── 2.mat              # Results from run 2
│   │   └── ...
│   └── Task2/
│       ├── 1.mat
│       ├── 2.mat
│       └── ...
└── AlgorithmB/
    ├── Task1/
    │   ├── 1.mat
    │   ├── 2.mat
    │   └── ...
    └── Task2/
        ├── 1.mat
        ├── 2.mat
        └── ...
```

Data conventions:

- First-level directory names identify algorithms; second-level directory names identify tasks.
- Load retrieves the **tasks shared by all algorithms currently listed**. Use the same directory name for the same task across algorithms.
- Run files must be numbered consecutively from `1.mat`. If Run number is `30`, every algorithm–task combination included in the analysis must provide `1.mat` through `30.mat`.
- The application reads the specified number of runs. It does not infer the run count or skip missing files automatically.
- The variables required inside each MAT file depend on the selected metric. The structure returned by `load` is passed directly to the metric function; different metrics may use different fields.

For example, the built-in `runtime` metric reads `data.runTime`. A compatible file can be created as follows:

```matlab
runTime = 12.34;  % Example runtime; use the same unit across experiments.
save('1.mat', 'runTime');
```

## Usage

### 1. Import Experiment Results

![Selecting the result folder](docs/images/result-path.png)

Click Select and choose the result root directory, such as `results/` above. Detected algorithms appear in the Algorithms list.

Use the right-click menu to remove algorithms you do not want to compare, then click Load to retrieve their shared tasks. The Tasks list also supports removing items and moving them up or down.

![Data import](docs/images/data-import.png)

### 2. Configure the Analysis

| Setting | Description |
| --- | --- |
| Metric | Metric used for the analysis |
| Run number | Number of runs to read for each algorithm on each task; default: 30 |
| Row Name | Header for the first column of the exported table; default: `Dataset` |

**The last algorithm in the list is the reference algorithm for statistical tests.** To use a particular algorithm as the reference, move it to the bottom using the right-click menu. Algorithm and task ordering also determines the column and row order in the result table.

![Changing the reference algorithm](docs/images/change-main-algorithm.png)

### 3. Generate and Interpret Results

Click Start to begin the analysis. The status changes to Busy during computation and returns to Free when computation finishes.

The table contains:

- **Task results**: The mean and sample standard deviation of the displayed metric values across runs, shown to four decimal places. One best algorithm per task is selected using the mean comparison value and highlighted in bold.
- **Significance symbols**: Each preceding algorithm is compared with the reference algorithm in the last column using a Wilcoxon rank-sum test at `p < 0.05`.
- **`+/=/-` row**: Counts of the significance symbols across tasks.
- **Rank row**: Friedman mean ranks computed from the mean comparison values for each task. Lower ranks are better; the best rank is highlighted in bold.

Symbols are interpreted from the perspective of the **reference algorithm in the last column**:

| Symbol | Meaning |
| --- | --- |
| `+` | The reference algorithm is significantly better than the algorithm in this column. |
| `=` | The difference is not significant, or the mean comparison values are equal. |
| `-` | The reference algorithm is significantly worse than the algorithm in this column. |

For example, `16/0/3` in the MOFS-BDE column means that the reference algorithm performs significantly better on 16 tasks, is recorded as tied on 0 tasks, and performs significantly worse on 3 tasks compared with MOFS-BDE.

No between-algorithm statistical tests are performed when only one algorithm is included. Friedman ranks require at least two algorithms and two tasks. The Wilcoxon test currently uses the unpaired rank-sum test, `ranksum`.

![Analysis results](docs/images/results.png)

### 4. Save and Reuse Configurations

Use **File → Save** to save the current configuration as a `.mat` file. Use **File → Open** to load it later, then click Start to recompute the results.

The configuration stores the result directory, algorithm and task lists and their ordering, the metric, run count, and row header. It does not include the original experiment data or the computed result table. If the data directory moves, select its new location.

Complete an analysis and confirm the settings before saving the configuration. The selected metric and run count are written to the working configuration when Start is clicked. After changing either setting, click Start again before saving.

### 5. Export a LaTeX Table

After the analysis, set Row Name and click Save within the Table tab to export the results as a `.tex` file.

The exported file includes an IEEEtran document wrapper and a `table*` environment. Compile it in a LaTeX environment with the required document class and packages to preview the table, or copy the table into your paper. Significance symbols, `\pm` between the mean and standard deviation, bold best results, and rankings are preserved. The `=` symbol shown in the interface is exported as `\approx`.

Adjust the caption, label, column widths, and layout to suit your paper. Underscores in algorithm and task names are escaped automatically; check other LaTeX special characters yourself.

![Exported LaTeX table](docs/images/latex-table.png)

## Custom Metrics

### Directory and Naming

Create a metric directory under `metrics/` and place its function inside:

```text
metrics/
└── MyScore/
    └── MyScoreMetric.m
```

The directory name becomes the metric name in the interface. Both the function name and filename must be the directory name followed by `Metric`, using a valid MATLAB function name. Restart the application after adding a metric; its directory will be loaded into the dropdown automatically.

### Function Interface

```matlab
function [realValue, refValue] = MyScoreMetric(data, taskName)
    % data: Structure returned by load for one run's MAT file.
    % taskName: Current task directory name; can identify reference data.
    % realValue: Metric value displayed for this run.
    % refValue: Comparison value used for statistical tests,
    %           best-result selection, and ranking.

    realValue = data.score;
    refValue = realValue;  % This example assumes lower scores are better.
end
```

Each call processes one run of one algorithm on one task. Both outputs should be finite real scalars. The main program handles means, standard deviations, and statistical tests across runs.

**Lower `refValue` values must always indicate better performance.** The application uses `realValue` to display the mean ± standard deviation, and `refValue` to select the best algorithm, perform statistical tests, and calculate ranks.

| Metric direction | Output setting |
| --- | --- |
| Lower is better, such as error rate or runtime | `refValue = realValue` |
| Higher is better, such as accuracy | `refValue = -realValue` |

For example, a custom metric that directly reads an accuracy value can be added as follows:

```text
metrics/
└── MyAccuracy/
    └── MyAccuracyMetric.m
```

```matlab
function [realValue, refValue] = MyAccuracyMetric(data, taskName)
    realValue = data.accuracy;
    refValue = -realValue;
end
```

Save `accuracy` as a top-level variable in each run file:

```matlab
accuracy = 0.95;
save('1.mat', 'accuracy');
```

Before using the metric in the application, check it independently in the command window:

```matlab
addpath(fullfile(pwd, 'metrics', 'MyAccuracy'));
data = load(fullfile('results', 'AlgorithmA', 'Task1', '1.mat'));
[realValue, refValue] = MyAccuracyMetric(data, 'Task1');
```

If a custom metric needs task-specific reference data, use `mfilename('fullpath')` to locate the metric directory and construct the data path using `taskName`. This avoids depending on the current working directory.

## Project Structure

```text
MetricPlix/
├── metricPlix.mlapp          # Main application and interface
├── docs/images/             # README screenshots
├── metrics/                 # Built-in and custom metrics and reference data
├── resources/               # Logo and other interface assets
├── templates/               # Reserved for templates
├── README.md                # English documentation
└── README.zh-CN.md          # Chinese documentation
```

## Feedback and Contact

Report bugs and suggest features through [GitHub Issues](https://github.com/fanrenkong/MetricPlix/issues). Include your MATLAB version, selected metric, directory structure, and error message. If experiment files are needed, provide a minimal example that reproduces the issue.

- Author: Kevin Kong
- Email: [kevin@fanrenkong.com](mailto:kevin@fanrenkong.com)
- Website: [www.fanrenkong.com](https://www.fanrenkong.com)
