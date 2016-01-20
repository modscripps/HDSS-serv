function T_hpr = T_HeadingPitchRoll(h, p, r)

% Pitch-roll transform
% PHINS convention for ship frame (x1=forward,x2=port,x3=up).

HeadingT	=	[	cosd(h)		-sind(h)	0
					sind(h)		cosd(h)		0
					0			0			1		];
				
PitchT		=	[	cosd(p)		0			-sind(p)
					0			1			0
					sind(p)		0			cosd(p) ];
		
RollT		=	[	1			0			0
					0			cosd(r)		-sind(r)
					0			sind(r)		cosd(r)	];
	
				
T_hpr = HeadingT * PitchT * RollT;

return