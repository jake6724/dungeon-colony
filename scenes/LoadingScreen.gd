class_name LoadingScreen
extends Control

@onready var main = get_tree().root.get_node("Main")
@onready var lm: LayerManager = main.get_node("LayerManager")
@onready var pf: PathFinder = lm.get_node("PathFinding")
@onready var color_rect = $ColorRect
@onready var progress_container = $ProgressBarVBox
@onready var label_container = $LabelVBox

@onready var sample_noise_progress_bar: ProgressBar = $ProgressBarVBox/SampleNoiseProgressBar
@onready var create_cell_progress_bar: ProgressBar = $ProgressBarVBox/CreateCellProgressBar
@onready var process_minerals_progress_bar: ProgressBar = $ProgressBarVBox/ProcessMineralsProgressBar
@onready var path_finding_add_points_progress_bar: ProgressBar = $ProgressBarVBox/PathFindingAddPointsProgressBar
@onready var path_finding_connect_points_progress_bar: ProgressBar = $ProgressBarVBox/PathFindingConnectPointsProgressBar

func update_progress_bar(progress_bar: ProgressBar, new_progress: float):
	progress_bar.value = new_progress

func test():
	print("test")