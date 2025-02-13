(function ($) {
"use strict";

/* meanmenu */
$('#mobile-menu').meanmenu({
	 meanMenuContainer: '.mobile-menu',
	 meanScreenWidth: "767"
 });
/* slider-active */
$('.slider-active').owlCarousel({
    loop:true,
    nav:false,
    responsive:{
        0:{
            items:1
        },
        600:{
            items:1
        },
        1000:{
            items:1
        }
    }
})
/* mixItUp */
$('#Container').mixItUp();

$('.image-link').magnificPopup({
  type: 'image',
  gallery:{
    enabled:true
  }
});

$('.video-popup').magnificPopup({
  type: 'iframe'
});

/* testimonial-active */
$('.testimonial-active').owlCarousel({
    loop:true,
    nav:false,
	dots:false,
	autoplay:true,
    responsive:{
        0:{
            items:1
        },
        600:{
            items:1
        },
        1000:{
            items:1
        }
    }
})

$('.counter').counterUp(900);

$('.feed-active').owlCarousel({
    loop:true,
    nav:true,
	dots:false,
	autoplay:true,
	navText:['<i class="fa fa-angle-left"></i>','<i class="fa fa-angle-right"></i>'],
    responsive:{
        0:{
            items:1
        },
        768:{
            items:3
        },
        1000:{
            items:5
        }
    }
})

$('.blog-active').owlCarousel({
    loop:true,
    nav:false,
    responsive:{
        0:{
            items:1
        },
        768:{
            items:2
        },
        1000:{
            items:3
        }
    }
})
/* brand-active */
$('.brand-active').owlCarousel({
    loop:true,
    nav:true,
	dots:false,
	navText:['<i class="fa fa-caret-left"></i>','<i class="fa fa-caret-right"></i>'],
    responsive:{
        0:{
            items:2
        },
        768:{
            items:4
        },
        1000:{
            items:6
        }
    }
})

    /*---------------------
       Circular Bars - Knob
    --------------------- */	
	  if(typeof($.fn.knob) != 'undefined') {
		$('.knob').each(function () {
		  var $this = $(this),
			  knobVal = $this.attr('data-rel');
	
		  $this.knob({
			'draw' : function () { 
			  $(this.i).val(this.cv + '%')
			}
		  });
		  
		  $this.appear(function() {
			$({
			  value: 0
			}).animate({
			  value: knobVal
			}, {
			  duration : 2000,
			  easing   : 'swing',
			  step     : function () {
				$this.val(Math.ceil(this.value)).trigger('change');
			  }
			});
		  }, {accX: 0, accY: -150});
		});
    }	




})(jQuery);	