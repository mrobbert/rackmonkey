// #####################################################################
// # RackMonkey - Know Your Racks - http://www.rackmonkey.org
// # Version 1.2.%BUILD%
// # (C)2007 Will Green (wgreen at users.sourceforge.net)
// # RackMonkey JavaScript library
// #####################################################################

// reverses the current check state of any checkbox with the specified fieldName
function checkboxInvert(fieldName)
{
	for (i = 0; i < fieldName.length; i++)
		fieldName[i].checked = !fieldName[i].checked;
}

// remove all the child nodes of the specified node
function removeChildNodes(node)
{
  	while (node.hasChildNodes())
	{
		node.removeChild(node.firstChild);
	}
}

function showHide(element)
{
	var ele = document.getElementById(element);
	if(!ele)
		return true;
	if(ele.style.display=="none")
	{
		ele.style.display="block"
	} 
	else 
	{
    	ele.style.display="none"
  	}
  return true;
}