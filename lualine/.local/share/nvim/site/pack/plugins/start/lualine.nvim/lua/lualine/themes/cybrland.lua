local colors = {
  no0			= '#030408',
  no2			= '#0A0E1A',
  wh0			= '#898D99',
  re0			= '#F24848',
  re2			= '#331215',
  gr0			= '#30F291',
  gr2			= '#0C3423',
  bl0			= '#3061F2',
  bl2			= '#0C1737',
  ye0			= '#F2D230',
  ye2			= '#332D10',
  me1			= '#212638',
  me2			= '#0D1120',
  me0			= '#4D5A80',
  vi0			= '#A130F2',
  vi2			= '#230D37'
}

return {
  normal = {
	a = { bg = colors.re0, fg = colors.re2, gui = 'bold' },
	b = { bg = colors.re2, fg = colors.re0 },
	c = { bg = colors.no0, fg = colors.wh0 },
  },
  insert = {
	a = { bg = colors.bl0, fg = colors.bl2, gui = 'bold' },
	b = { bg = colors.bl2, fg = colors.bl0 },
	c = { bg = colors.no0, fg = colors.wh0 },
  },
  visual = {
	a = { bg = colors.ye0, fg = colors.ye2, gui = 'bold' },
	b = { bg = colors.ye2, fg = colors.ye0 },
	c = { bg = colors.no0, fg = colors.wh0 },
  },
  replace = {
	a = { bg = colors.vi0, fg = colors.vi2, gui = 'bold' },
	b = { bg = colors.vi2, fg = colors.vi0 },
	c = { bg = colors.no0, fg = colors.wh0 },
  },
  command = {
	a = { bg = colors.gr0, fg = colors.gr2, gui = 'bold' },
	b = { bg = colors.gr2, fg = colors.gr0 },
	c = { bg = colors.no0, fg = colors.wh0 },
  },
  inactive = {
	a = { bg = colors.re2, fg = colors.wh0, gui = 'bold' },
	b = { bg = colors.re2, fg = colors.wh0 },
	c = { bg = colors.re2, fg = colors.wh0 },
  },
}
