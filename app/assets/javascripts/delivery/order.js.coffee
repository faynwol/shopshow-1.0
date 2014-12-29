App.Orders = 
	checkPrepareProducts: (order_id, dom) ->			
		$(dom).find('button').button('loading')
		$.post '/delivery/orders/' + order_id + '/check_prepare_products', (res) ->					
			window.location.reload()

	delivery: (order_id, dom) ->		
		$(dom).find('button').button('loading')
		$.post '/delivery/outbounds', {order_id: order_id}, (res) ->
			if res.success
				window.location.reload()
			else
				$(dom).find('button').button('reset')
				alert('出库出错！请重试')
		, 'json'

	notifyCarriage: (order_id, dom) ->
		$(dom).find('button').button('loading')
		$.post '/delivery/orders/' + order_id + '/notify_carriage', (res) ->
			if res.success
				alert('已经通知用户缴纳运费!')
				$(dom).find('button').button('reset')

		, 'json'	

	notifyTax: (order_id, dom) ->
		$(dom).find('button').button('loading')
		$.post '/delivery/orders/' + order_id + '/notify_tax', (res) ->
			if res.success
				alert('已经通知用户缴纳关税!')
				$(dom).find('button').button('reset')
		, 'json'

$(document).ready ->
	$('a.orderDetail').click ->		
	  outbound_id = $(this).attr('outbound_id')	  
	  dialog = artDialog
	    width: 400
	    title: "物流详情"          	    

	    onshow: ->
	    	$.get '/delivery/outbounds/' + outbound_id + '/query' , (res) =>
	    		_this.content(res)
	    	, 'html'
	    ok: =>   	    		      

	    okValue: '确定'
	    cancel: ->
	    cancelValue: '取消'
	  
	  dialog.showModal()		