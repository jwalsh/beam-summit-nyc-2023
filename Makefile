# Pattern rule with name prefix in target file
%.png: %.dot
	$(DOT_CMD) $< -o $*-graph.png
