#= require bootstrap-datetimepicker.min

App.LiveShow = 
  
	uploadTemplate: '<img src="/assets/delivery/loading.gif" class="img-thumbnail" width="200" border="0"  />'

	closeLiveShow: (live_show_id, countdown) ->  		
	  dialog = artDialog
	    width: 400
	    title: "关闭直播室"          
	    content: """
  			<div class='form-group close-dialog' style='line-height:30px'>
  				<div class='pull-left'>您确定在</div>
  				<div class='pull-left col-xs-2'><input id='countdown' class='form-control input-sm' value='#{countdown}'/></div>
  				<div class='pull-left'>分钟以后结束购买吗?</div>
  			</div>
      """  
	    ok: =>   	    	
	      window.location.href = "/delivery/live_shows/" + live_show_id + "/close?countdown=" + $('input#countdown').val()
	    okValue: '确定'
	    cancel: ->
	    cancelValue: '取消'

	  dialog.showModal()

	uploadPreview : ->
		# 本地预览上传图片
		$("#live_show_preview").change (e) ->
			$t = $(this)

			if e.target.files && e.target.files[0]
				f = e.target.files[0]
				if f.type.match("image.*")
					reader = new FileReader()
					reader.readAsDataURL f
					reader.onload = (evt) ->
						$pane = $("""
							<div class="image-preview">
								<img width='300' height='180' />
								<div class="ops">
									<button class="btn btn-default" type="button">
										<i class="fa fa-trash mr-5"></i>
										<span>删除</span>
									</button>
								</div>
							</div>
						""")
						
						$pane.find('img').attr 'src', evt.target.result
						$t.parents(".preview").append $pane
						$t.parent().hide()
				else
					alert "请上传正确格式的图片"

		# 删除准备上传的图片
		$(".preview").on "click", ".image-preview button", ->
			$(this).parents(".image-preview").remove()
			$("#live_show_preview").val ""
			$(".preview .plus").show()
  
$(document).ready ->	
	App.LiveShow.uploadPreview()		


	$("#live_show_start_time").datetimepicker(
	  todayBtn: true
	  format: "yyyy-mm-dd hh:ii"
	  startDate: new Date
	  autoclose: true
		showTimezone: true 
		timezone: "+0800"
	).on "show", ->
	  top = $("#live_show_start_time").offset().top + 20
	  $("span.glyphicon.glyphicon-arrow-left").removeClass("glyphicon glyphicon-arrow-left").addClass "fa fa-arrow-left"
	  $("span.glyphicon.glyphicon-arrow-right").removeClass("glyphicon glyphicon-arrow-right").addClass "fa fa-arrow-right"
	  $(".datetimepicker.datetimepicker-dropdown-bottom-right.dropdown-menu").css "top", top	  
