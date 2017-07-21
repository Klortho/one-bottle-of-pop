@{%
  function hey() { console.log('hey'); }
  function r(rule, f) {
	  return function(d, l, r) {
		  console.log(`${l} ${rule}: `, d);
		  return f(d, l, r);
	  }
  }
  const identity = rule => r(rule, d => d);
  const flatten = rule => r(rule, d => {
	  const sel = d.find(e => e !== null);
	  console.log('array ' + d + ', returning  ' + sel);
	  return sel;
  });
%}

#SVG_PATH -> WSP:* MOVETO_DRAWTO_CMD_GROUPS:? WSP:*  {% flatten('svg_path') %}
#MOVETO_DRAWTO_CMD_GROUPS -> MOVETO_DRAWTO_CMD_GROUP {% identity('moveto_drawto_cmd_groups') %}
#    | MOVETO_DRAWTO_CMD_GROUP WSP:* MOVETO_DRAWTO_CMD_GROUPS
MOVETO_DRAWTO_CMD_GROUP -> MOVETO WSP:* DRAWTO_CMDS:? {% d => [d[0], d[2]] %}

DRAWTO_CMDS -> DRAWTO_CMD
    | DRAWTO_CMD WSP:* DRAWTO_CMDS
DRAWTO_CMD -> CLOSEPATH
    | LINETO
	| HORIZ_LINETO
	| VERT_LINETO
	| CURVETO
	| SMOOTH_CURVETO
	| QBEZIER_CURVETO
	| SMOOTH_QBEZIER_CURVETO
	| ARC

MOVETO -> ("M"|"m") WSP:* MOVETO_ARG_SEQ {% d => d[2] %}
MOVETO_ARG_SEQ -> COORDS {% d => d[0] %}
    | COORDS CWSP:? LINETO_ARG_SEQ

CLOSEPATH -> ("Z" | "z")

LINETO -> ("L" | "l") WSP:* LINETO_ARG_SEQ
LINETO_ARG_SEQ -> COORDS
    | COORDS CWSP:? LINETO_ARG_SEQ

HORIZ_LINETO -> ("H"|"h") WSP:* HORIZ_LINETO_ARG_SEQ
HORIZ_LINETO_ARG_SEQ -> COORD

| COORD CWSP:? HORIZ_LINETO_ARG_SEQ
VERT_LINETO -> ("V"|"v") WSP:* VERT_LINETO_ARG_SEQ
VERT_LINETO_ARG_SEQ -> COORD
    | COORD CWSP:? VERT_LINETO_ARG_SEQ

CURVETO -> ("C"|"c") WSP:* CURVETO_ARG_SEQ
CURVETO_ARG_SEQ -> CURVETO_ARG
    | CURVETO_ARG CWSP:? CURVETO_ARG_SEQ
CURVETO_ARG -> COORDS CWSP:? COORDS CWSP:? COORDS

SMOOTH_CURVETO -> ("S"|"s") WSP:* SMOOTH_CURVETO_ARG_SEQ
SMOOTH_CURVETO_ARG_SEQ -> SMOOTH_CURVETO_ARG
    | SMOOTH_CURVETO_ARG CWSP:? SMOOTH_CURVETO_ARG_SEQ
SMOOTH_CURVETO_ARG -> COORDS CWSP:? COORDS

QBEZIER_CURVETO -> ("Q"|"q") WSP:* QBEZIER_CURVETO_ARG_SEQ
QBEZIER_CURVETO_ARG_SEQ -> QBEZIER_CURVETO_ARG
    | QBEZIER_CURVETO_ARG CWSP:? QBEZIER_CURVETO_ARG_SEQ
QBEZIER_CURVETO_ARG -> COORDS CWSP:? COORDS

SMOOTH_QBEZIER_CURVETO -> ("T"|"t") WSP:* SMOOTH_QBEZIER_CURVETO_ARG_SEQ
SMOOTH_QBEZIER_CURVETO_ARG_SEQ -> COORDS
    | COORDS CWSP:? SMOOTH_QBEZIER_CURVETO_ARG_SEQ

ARC -> ("A"|"a") WSP:* ARC_ARG_SEQ
ARC_ARG_SEQ -> ARC_ARG
    | ARC_ARG CWSP:? ARC_ARG_SEQ
ARC_ARG -> NONNEG_NUMBER CWSP:? NONNEG_NUMBER CWSP:? NUMBER CWSP:? FLAG CWSP:? FLAG CWSP:? COORDS

COORDS -> COORD CWSP:? COORD {% d => [d[0], d[2]] %}
COORD -> NUMBER {% d => d[0] %}
NONNEG_NUMBER -> INT | FLOAT
NUMBER -> MAYBE_SIGN INT {% d => (d[0] === null ? 1 : d[0]) * d[1] %}
    | SIGN:? FLOAT
FLAG -> "0"|"1"

CWSP -> WSP:+
    | WSP:* "," WSP:*

INT -> DIGITS  {% d => { console.log(`int ${d[0]}`); return d[0]; } %}
FLOAT -> FRACTION EXP:?
    | DIGITS EXP

FRACTION -> DIGITS:? "." DIGITS
    | DIGITS "."
EXP -> ("E"|"e") SIGN:? DIGITS
MAYBE_SIGN -> SIGN:? {% d => d[0] === null ? 1 : d[0] %}
SIGN -> "+"|"-"  {% d => d[0] === '-' ? -1 : 1 %}
DIGITS -> [0-9]:+  {% d => { var str = d[0].join(''); hey(); console.log('digits: ', str); return parseInt(str); } %}
WSP -> " "|"\t"|"\n"|"\r"  {% () => null %}
