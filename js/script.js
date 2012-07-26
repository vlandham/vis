function addCommas(nStr)
{
	nStr += '';
	x = nStr.split('.');
	x1 = x[0];
	x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}

function roundNumber(num, dec) {
	var result = Math.round(num*Math.pow(10,dec))/Math.pow(10,dec);
	return result;
}


function fixUp(number)
{
  if(number > 999999999)
  {
    number = roundNumber(number / 1000000000.0, 1);
    return addCommas(number) + "B";
  }
  else if(number > 999999)
  {
    number = roundNumber(number / 1000000.0, 1);
    return addCommas(number) + "M";

  }
  else
  {
    return addCommas(number);
  }
}























