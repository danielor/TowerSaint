package character
{
	import mx.controls.Alert;

	public class CharacterNameGenerator
	{
		public static var latinAndGreek:Array =  ['vol', 'viv', 'vit', 'ven', 'van', 'vel','zo', 'urb', 'urg', 'unc', 'ulo', 'trin',
			'trem', 'tri', 'tot', 'tim', 'the', 'tep', 'tax', 'sud', 'sui', 'styl', 'sten', 'su',
			'st', 'son', 'sol', 'sil', 'ser', 'sen', 'sei','sed', 'seb', 'sfi', 'sax', 'san',
			'sax', 'rur', 'rug', 'rot', 'rog', 'rod', 'rhe', 'ren', 'rar', 'ran', 'rad', 'ras',
			'qui', 'put', 'pur', 'pup', 'pto', 'pro', 'pre', 'pot', 'pon', 'por', 'pol', 'pod',
			'plu', 'pis', 'pir', 'pin', 'pil', 'pic', 'pet', 'per', 'pen', 'ped','pav', 'pat',
			'pan', 'pam', 'pal', 'pac', 'oxy', 'ovi', 'ov', 'ot','orn','or', 'opt', 'oo', 'ont',
			'omo', 'omm', 'oma',  'ole', 'oen', 'oed', 'od', 'oct', 'ob', 'o', 'oc', 'os', 'nuc',
			'nub', 'nu', 'nox', 'noc', 'nov', 'not', 'non', 'nod', 'nes', 'neg', 'nav', 'nas', 'nar',
			'myz', 'myx', 'my', 'mut', 'mus', 'mur', 'mov', 'mot', 'mon', 'mol', 'mne', 'mit', 'mis',
			'mir', 'min', 'mim', 'mic', 'mes', 'mer', 'mei', 'mar', 'man', 'mal', 'maj', 'lun', 'lud',
			'lus', 'luc', 'log', 'loc', 'lin', 'lig', 'lev', 'lep', 'leg', 'lax', 'lav', 'lat', 'lab',
			'juv', 'jut', 'jus', 'jur', 'jug', 'joc', 'jac', 'is', 'iso', 'in', 'il', 'im', 'ir', 
			'ign', 'idi', 'ide', 'id', 'hor', 'hod', 'hex', 'hen', 'hai', 'hei', 'hab', 'hib', 'gyn',
			'ger', 'gen', 'gel', 'ge', 'geo', 'fur', 'fum', 'fug', 'for', 'flu', 'fl', 'fin', 'fil',
			'fic', 'fis', 'fet','fer', 'fel', 'fat', 'fab','exo', 'ex', 'ef', 'eur', 'eu', 'eso',
			'err', 'erg', 'equ', 'iqu', 'epi', 'ep', 'ens', 'en', 'em', 'eme', 'ego', 'eg', 'ed', 
			'es', 'ec', 'eco', 'dys', 'dy', 'dur', 'dub', 'du', 'dom', 'dia', 'di', 'den', 'deb', 
			'de', 'cyt', 'cut', 'cub', 'cre', 'con', 'co', 'col', 'com', 'cor', 'col', 'civ', 'cen',
			'ced', 'cav', 'can', 'cap', 'cip', 'can', 'cin', 'cad', 'cis', 'cas', 'cac', 'bov',
			'bor', 'bon', 'bi', 'bio', 'bib', 'bi', 'ben', 'be', 'bac', 'axi', 'avi', 'aut', 'aur',
			'aud', 'ar', 'aqu', 'apo', 'ant', 'ann', 'enn', 'ana', 'an', 'am', 'alb', 'ad', 'ac', 
			'af', 'ag', 'al', 'ap', 'ar', 'as', 'at', 'acr', 'ac', 'ab', 'abs'];
		public function CharacterNameGenerator()
		{
			
		}
		
		public static function generateName(numberOfRoots:Number):String {
			var name:String = "";
			Alert.show(CharacterNameGenerator.latinAndGreek.length.toString());
			for(var i:int = 0; i < numberOfRoots; i++){
				var nj:int = int(Math.random() * CharacterNameGenerator.latinAndGreek.length);
				name += CharacterNameGenerator.latinAndGreek[nj];
			}
			return name;
		}
		
	}
}