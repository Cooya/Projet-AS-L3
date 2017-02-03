$(document).on('mouseenter', '.syntaxIdentifier', function(event) {
	$('.symbol'+$(this).attr('symbol')).addClass('syntaxHighlight');
});

$(document).on('mouseleave', '.syntaxIdentifier', function(event) {
	$('.symbol'+$(this).attr('symbol')).removeClass('syntaxHighlight');
});


$(document).on('click', '.blockButton', function(event) {
	if($(this).attr('status') == 1)
		$(this).children().html('+');
	else
		$(this).children().html('-');

	$(this).attr('status', 1-$(this).attr('status'));

	$('#block'+$(this).attr('block')).stop(true, true).slideToggle(100);

	$('#blockEllipsis'+$(this).attr('block')).toggle();
});

$(document).on('click', '.syntaxIdentifier', function(event) {
	$('#symbol'+$(this).attr('symbol'))
		.parent()
		.stop(true, true)
		.css('background-color', 'rgba(255, 251, 204, 0.4)')
		.animate({
    		backgroundColor: 'rgba(255, 251, 204, 0)'
		}, 5000);
});