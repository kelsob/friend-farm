extends Resource

class_name QualityTier

export (int) var tier = 0
export (String) var letter_tier = ""
export (String) var name = ""
export (float) var quality_threshold = 0.0
export (float) var quality_threshold_to_next = 0.0
export (float) var value_modifier = 1.25

export (String) var RTEffect_open_primary = "[sparkle c1=yellow c2=orange]"
export (String) var RTEffect_close_primary = "[/sparkle]"
export (String) var RTEffect_open_secondary = ""
export (String) var RTEffect_close_secondary = ""
export (String) var RTEffect_open_tertiary = ""
export (String) var RTEffect_close_tertiary = ""

export (Resource) var next_quality_tier 
