package options;

import flixel.FlxG;

using StringTools;

class ParitySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Parity Settings';
		rpcTitle = 'Parity Settings Menu'; //for Discord Rich Presence
		var option:Option = new Option('Psych Camera Behaviour',
			'If checked, the camera zoom will not update before the first note is played.',
			'psychCam',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Psych Sustain Scroll Behaviour', //Name
			'If checked, sustains will not flip if a note changes scroll directions.', //Description
			'psychSustain', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Disable Marv Hit Window', //Name
			'If checked, the smallest added hit window (Marv) will be disabled.', //Description
			'disableMarv', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Psych Time Bar',
			"If checked, the Time Bar will look like it does in Psych Engine.",
			'psychTimeBar',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Decenter Strumlines', //Name
			'If checked, the strumlines will be re-moved to the left by 6 pixels.\nIf you need that for something.', //Description
			'decenterStrums', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		super(0xffffffff);
	}

}