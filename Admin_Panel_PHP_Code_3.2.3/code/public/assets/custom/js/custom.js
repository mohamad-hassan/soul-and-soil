$(function() {
	// Hide the card body initially
	$("#add_card").hide();

	// Toggle the card body when the button is clicked
	$("#toggleButton").click(function() {
		$("#add_card").slideToggle();
	});

	$(".select2-multiple").select2();

	getWordCount("meta_title", "meta_title_count", "19.9px arial");
	getWordCount("meta_description", "meta_description_count", "12.9px arial");
	getWordCount("edit_meta_title", "edit_meta_title_count", "19.9px arial");
	getWordCount(
		"edit_meta_description",
		"edit_meta_description_count",
		"12.9px arial"
	);
	// First register any plugins
	FilePond.registerPlugin(
		FilePondPluginImagePreview,
		FilePondPluginFileValidateSize,
		FilePondPluginFileValidateType
	);
	// Turn input element into a pond
	$(".filepond").filepond({
		credits: null,
		allowFileSizeValidation: "true",
		maxFileSize: "25MB",
		labelMaxFileSizeExceeded: "File is too large",
		labelMaxFileSize: "Maximum file size is {filesize}",
		allowFileTypeValidation: true,
		acceptedFileTypes: ["image/*"],
		labelFileTypeNotAllowed: "File of invalid type",
		fileValidateTypeLabelExpectedTypes: "Expects {allButLastType} or {lastType}",
		storeAsFile: true,
		allowPdfPreview: true,
		pdfPreviewHeight: 320,
		pdfComponentExtraParams: "toolbar=0&navpanes=0&scrollbar=0&view=fitH",
	});

	$(".filepond-video").filepond({
		credits: null,
		allowFileSizeValidation: "true",
		maxFileSize: "25MB",
		labelMaxFileSizeExceeded: "File is too large",
		labelMaxFileSize: "Maximum file size is {filesize}",
		allowFileTypeValidation: true,
		acceptedFileTypes: ["video/*"],
		labelFileTypeNotAllowed: "File of invalid type",
		fileValidateTypeLabelExpectedTypes: "Expects {allButLastType} or {lastType}",
		storeAsFile: true,
		allowPdfPreview: true,
		pdfPreviewHeight: 320,
		pdfComponentExtraParams: "toolbar=0&navpanes=0&scrollbar=0&view=fitH",
	});

	$(".filepond-json").filepond({
		credits: null,
		allowFileSizeValidation: "true",
		maxFileSize: "25MB",
		labelMaxFileSizeExceeded: "File is too large",
		labelMaxFileSize: "Maximum file size is {filesize}",
		allowFileTypeValidation: true,
		acceptedFileTypes: ["application/JSON"],
		labelFileTypeNotAllowed: "File of invalid type",
		fileValidateTypeLabelExpectedTypes: "Expects {allButLastType} or {lastType}",
		storeAsFile: true,
		allowPdfPreview: true,
		pdfPreviewHeight: 320,
		pdfComponentExtraParams: "toolbar=0&navpanes=0&scrollbar=0&view=fitH",
	});

	$('.fa').popover({
		trigger: "manual",
		html: true,
	}).on('click', function() {
		$(this).popover('toggle');
	});

	// Enable links inside the popover to be clickable
	$('body').on('click', '.popover-content a', function(e) {
		e.stopPropagation();
	});

	// Close the popover when clicking outside of it
	$('body').on('click', function(e) {
		if (!$('.fa').is(e.target) && $('.fa').has(e.target).length === 0 && $('.popover').has(e
				.target).length === 0) {
			$('.fa').popover('hide');
		}
	});
});

$("#create_form").on("submit", function(e) {
	e.preventDefault();
	if ($(this).valid()) {
		let formElement = $(this);
		let submitButtonElement = $(this).find(":submit");
		let url = $(this).attr("action");
		let data = new FormData(this);

		function successCallback() {
			$("#table").bootstrapTable("refresh");
			formElement[0].reset();
			setTimeout(function() {
				let filePondElements = document.getElementsByClassName("filepond");
				// Iterate over all elements with the specified class
				for (let i = 0; i < filePondElements.length; i++) {
					let filePond = FilePond.find(filePondElements[i]);
					if (filePond != null) {
						// This will remove all files for each FilePond instance
						filePond.removeFiles();
					}
				}

				let filePondElements1 =
					document.getElementsByClassName("filepond-json");
				// Iterate over all elements with the specified class
				for (let i = 0; i < filePondElements1.length; i++) {
					let filePond = FilePond.find(filePondElements1[i]);
					if (filePond != null) {
						// This will remove all files for each FilePond instance
						filePond.removeFiles();
					}
				}

				let filePondElements2 = document.getElementsByClassName("filepond-video");
				// Iterate over all elements with the specified class
				for (let i = 0; i < filePondElements2.length; i++) {
					let filePond = FilePond.find(filePondElements2[i]);
					if (filePond != null) {
						// This will remove all files for each FilePond instance
						filePond.removeFiles();
					}
				}

				$(this).find("select").val('').trigger("change");
				$('#order_language_id').trigger('change');
				$('#tag_id').val('').trigger('change');
				$('#category_ids').val('').trigger('change');
				$('#news_ids').val('').trigger('change');
				if (typeof resetUserCategorySwitch === 'function') {
					resetUserCategorySwitch();
				}
			}, 500);
		}

		formAjaxRequest("POST", url, data, formElement, submitButtonElement, successCallback);
	}
});

$("#update_form").on("submit", function(e) {
	if ($(this).valid()) {
		e.preventDefault();
		let formElement = $(this);
		let submitButtonElement = $(this).find(":submit");
		let data = new FormData(this);
		data.append("_method", "PUT");
		let url = $(this).attr("action") + "/" + data.get("edit_id");

		function successCallback(response) {
			// console.log(response);
			$("#table").bootstrapTable("refresh");
			setTimeout(function() {
				$("#editDataModal").modal("hide");
				formElement[0].reset();

				let filePondElements = document.getElementsByClassName("filepond");

				// Iterate over all elements with the specified class
				for (let i = 0; i < filePondElements.length; i++) {
					let filePond = FilePond.find(filePondElements[i]);

					if (filePond != null) {
						// This will remove all files for each FilePond instance
						filePond.removeFiles();
					}
				}
				let filePondElements1 =
					document.getElementsByClassName("filepond-json");

				// Iterate over all elements with the specified class
				for (let i = 0; i < filePondElements1.length; i++) {
					let filePond = FilePond.find(filePondElements1[i]);

					if (filePond != null) {
						// This will remove all files for each FilePond instance
						filePond.removeFiles();
					}
				}
				$('#order_language_id').trigger('change');
				// $("select").val(false).trigger("change");
			}, 1000);
		}

		formAjaxRequest("POST", url, data, formElement, submitButtonElement, successCallback);
	}
});

function showErrorToast(message) {
	Swal.fire({
		toast: true,
		icon: "error",
		title: message,
		position: "top-end",
		showConfirmButton: false,
		timer: 3000,
		timerProgressBar: true,
		didOpen: (toast) => {
			toast.addEventListener("mouseenter", Swal.stopTimer);
			toast.addEventListener("mouseleave", Swal.resumeTimer);
		},
	});
}

function showSuccessToast(message) {
	Swal.fire({
		toast: true,
		icon: "success",
		title: message,
		position: "top-end",
		showConfirmButton: false,
		timer: 3000,
		timerProgressBar: true,
		didOpen: (toast) => {
			toast.addEventListener("mouseenter", Swal.stopTimer);
			toast.addEventListener("mouseleave", Swal.resumeTimer);
		},
	});
}

$.ajaxSetup({
	headers: {
		"X-CSRF-TOKEN": $('meta[name="csrf-token"]').attr("content"),
	},
});

function ajaxRequest(type, url, data, beforeSendCallback, successCallback, errorCallback, finalCallback) {
	/*
	 * @param
	 * beforeSendCallback : This function will be executed before Ajax sends its request
	 * successCallback : This function will be executed if no Error will occur
	 * errorCallback : This function will be executed if some error will occur
	 * finalCallback : This function will be executed after all the functions are executed
	 */
	$.ajax({
		type: type,
		url: url,
		data: data,
		cache: false,
		processData: false,
		contentType: false,
		dataType: "json",
		beforeSend: function() {
			if (beforeSendCallback != null) {
				beforeSendCallback();
			}
		},
		success: function(data) {
			if (!data.error) {
				if (data.message) {
					showSuccessToast(data.message);
				}
				if (successCallback != null) {
					successCallback(data);
				}
			} else {
				showErrorToast(data.message);
				if (errorCallback != null) {
					errorCallback(data);
				}
			}

			if (finalCallback != null) {
				finalCallback(data);
			}
		},
		error: function(jqXHR, textStatus, errorThrown, data) {
			if (jqXHR.responseJSON.message) {
				showErrorToast(jqXHR.responseJSON.message);
			}
			if (finalCallback != null) {
				finalCallback();
			}
		},
	});
}

function formAjaxRequest(type, url, data, formElement, submitButtonElement, successCallback, errorCallback) {
	if (formElement) {
		let submitButtonText = submitButtonElement.val();

		function beforeSendCallback() {
			submitButtonElement.val("Please Wait...").attr("disabled", true);
		}

		function finalCallback(response) {
			submitButtonElement.val(submitButtonText).attr("disabled", false);
		}
		ajaxRequest(type, url, data, beforeSendCallback, successCallback, errorCallback, finalCallback);
	}
}

$(document).on("click", ".delete-form", function(e) {
	e.preventDefault();
	Swal.fire({
		title: "Are you sure?",
		text: "You won't be able to revert this!",
		icon: "warning",
		showCancelButton: true,
		confirmButtonColor: "#3085d6",
		cancelButtonColor: "#d33",
		confirmButtonText: "Yes, delete it!",
	}).then((result) => {
		if (result.isConfirmed) {
			let url = $(this).attr("data-url");
			let data = {
				_token: "{!! csrf-token() !!}",
			};
			function successCallback() {
				$("#table").bootstrapTable("refresh");	
				setTimeout(() => {
					$('#order_language_id').trigger('change');
				}, 1000);		
			}
			ajaxRequest("DELETE", url, data, null, successCallback);
		}
	});
});

function fetchList(url, data, targetElement) {
	$.ajax({
		url: url,
		type: "POST",
		data: data,
		beforeSend: function() {
			$(targetElement).html("Please wait..");
		},
		success: function(result) {
			$(targetElement).html(result);
		},
		error: function(errors) {
			console.log(errors);
		},
	});
}

$(".modal").on("hidden.bs.modal", function() {
	let filePondElements = document.getElementsByClassName("filepond");

	// Iterate over all elements with the specified class
	for (let i = 0; i < filePondElements.length; i++) {
		let filePond = FilePond.find(filePondElements[i]);

		if (filePond != null) {
			// This will remove all files for each FilePond instance
			filePond.removeFiles();
		}
	}

	let filePondElements1 = document.getElementsByClassName("filepond-video");

	// Iterate over all elements with the specified class
	for (let i = 0; i < filePondElements1.length; i++) {
		let filePond = FilePond.find(filePondElements1[i]);

		if (filePond != null) {
			// This will remove all files for each FilePond instance
			filePond.removeFiles();
		}
	}
	// put your default event here
	$("#youtube_url").val("");
	$("#other_url").val("");
	$("#exampleVideoInputFile1_edit").val("");
});

function getWordCount(fiels_type = "", field_counter = "", font = "0px arial") {
	let textArea = document.getElementById(fiels_type);
	let characterCounter = document.getElementById(field_counter);

	if (textArea && characterCounter) {
		const text = textArea.value;
		const canvas = document.createElement("canvas");
		const context = canvas.getContext("2d");
		context.font = font;
		const width = context.measureText(text).width;
		const finalWidth = Math.ceil(width);
		textdata = "";
		info_data = "";
		var fiels_type_value = "";
		if (fiels_type == "meta_title") {
			fiels_type_value = "Meta title";
		} else if (fiels_type == "meta_description") {
			fiels_type_value = "Meta description";
		} else if (fiels_type == "edit_meta_title") {
			fiels_type_value = "Meta title";
		} else if (fiels_type == "edit_meta_description") {
			fiels_type_value = "Meta description";
		}

		if (fiels_type == "meta_title") {
			less_equal = 240;
			less_equal2 = 580;
			textdata = "<span>Title " + textdata + " is <b>" + finalWidth + "</b> pixel(s) long</span>";
		} else if (fiels_type == "meta_description") {
			less_equal = 395;
			less_equal2 = 920;
			textdata = "<span>Meta Description " + textdata + " is <b>" + finalWidth + "</b> pixel(s) long</span>";
		} else if (fiels_type == "edit_meta_title") {
			less_equal = 240;
			less_equal2 = 580;
			textdata = "<span>Title " + textdata + " is <b>" + finalWidth + "</b> pixel(s) long</span>";
		} else if (fiels_type == "edit_meta_description") {
			less_equal = 395;
			less_equal2 = 920;
			textdata = "<span>Meta Description " + textdata + " is <b>" + finalWidth + "</b> pixel(s) long</span>";
		}

		if (finalWidth <= less_equal) {
			info_class = "text-danger";
			info_icon = '<i class="fa fa-exclamation-triangle ' + info_class + '"></i>';
			info_data = "<span class=" + info_class + ">--Your page " + fiels_type_value + " is too short.</span>";
		} else if (finalWidth > less_equal && finalWidth <= less_equal2) {
			info_class = "text-success";
			info_icon = '<i class="fa fa-check-circle ' + info_class + '"></i>';
			info_data = "<span class=" + info_class + ">--Your page " + fiels_type_value + " is an acceptable length.</span>";
		} else if (finalWidth > less_equal2) {
			info_class = "text-danger";
			info_icon =
				'<i class="fa fa-exclamation-triangle ' + info_class + '"></i>';
			info_data = "<span class=" + info_class + ">--Page " + fiels_type_value + " should be around " + less_equal2 + " pixels in length.</span>";
		}
		characterCounter.innerHTML = info_icon + " " + textdata + info_data;
	}
}