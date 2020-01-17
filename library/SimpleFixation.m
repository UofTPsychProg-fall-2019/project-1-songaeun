function SimpleFixation(wptr, rect, cross_r, cross_color, cross_t, circle_r, circle_color, offset)
	if ~exist('cross_t', 'var')  || isempty(cross_t)  cross_t = 2; end %#ok<SEPEX>
	if ~exist('circle_r', 'var') || isempty(circle_r) circle_r = 0; end %#ok<SEPEX>
	if ~exist('offset', 'var')   || isempty(offset)   offset = [0 0]; end %#ok<SEPEX>

	[cx, cy] = RectCenter(rect);
	cpair = [cx, cy] + offset;
	circle_rect = repmat(cpair, 1, 2) + round([-1 -1 1 1] * circle_r);
	cross_coords = [-1, 1, 0, 0; 0, 0, -1, 1] * cross_r;
	if circle_r > 0
		Screen('FillOval', wptr, circle_color, circle_rect);
	end
	Screen('DrawLines', wptr, cross_coords, cross_t, cross_color, cpair, 1);
end