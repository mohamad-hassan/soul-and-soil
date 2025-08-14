'use client'
import React, { useState, useEffect } from 'react';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Autoplay } from 'swiper/modules';
// Import Swiper styles
import 'swiper/css';
import 'swiper/css/free-mode';
import 'swiper/css/pagination';


// import required modules
import Image from 'next/image';
import earthImg from '../../../../assets/Images/earthImage.png'
import StyleFiveCard from './StyleFiveCard';
import { useRef } from 'react';
import { useCallback } from 'react';
import { FaAngleLeft, FaAngleRight } from "react-icons/fa6";
import AdSpace from '@/components/commonComponents/adSpace/AdSpace';
import Link from 'next/link';
import { currentLangCode, getDirection, placeholderImage, translate } from '@/utils/helpers';
import { useSelector } from 'react-redux';
import { currentLanguageSelector } from '@/components/store/reducers/languageReducer';


const StyleFive = ({ Data }) => {

  const currLangCode = currentLangCode();

  const currentLanguage = useSelector(currentLanguageSelector);

  const showNavigation = Data.news?.length > 1

  const showNavigationBreaking = Data.breaking_news?.length > 1

  const showNavigationVideo = Data.videos?.length > 1

  // Add state variables to track current slide positions
  const [currentNewsSlide, setCurrentNewsSlide] = useState(0)
  const [currentVideoSlide, setCurrentVideoSlide] = useState(0)
  const [currentBreakingSlide, setCurrentBreakingSlide] = useState(0)

  // Add state to track window width for responsive slides per view
  const [windowWidth, setWindowWidth] = useState(1200)

  // Add refs for each swiper
  const newsSliderRef = useRef(null);
  const videoSliderRef = useRef(null);
  const breakingSliderRef = useRef(null);

  const swiperOption = {
    speed: 750,
    spaceBetween: 20,
    slidesPerView: 2,
    navigation: showNavigation,
    breakpoints: {
      0: {
        slidesPerView: 1
      },

      768: {
        slidesPerView: 2
      },

      992: {
        slidesPerView: 2
      },
      1200: {
        slidesPerView: 3
      }
    },
    autoplay: true,
    // Add slide change event handler
    onSlideChange: (swiper) => {
      setCurrentNewsSlide(swiper.activeIndex)
    }
  }

  const swiperOptionVideo = {
    speed: 750,
    spaceBetween: 20,
    slidesPerView: 2,
    navigation: showNavigationVideo,
    breakpoints: {
      0: {
        slidesPerView: 1
      },

      768: {
        slidesPerView: 2
      },

      992: {
        slidesPerView: 2
      },
      1200: {
        slidesPerView: 3
      }
    },
    autoplay: true,
    // Add slide change event handler
    onSlideChange: (swiper) => {
      setCurrentVideoSlide(swiper.activeIndex)
    }
  }

  const swiperOptionBreaking = {
    speed: 750,
    spaceBetween: 20,
    slidesPerView: 2,
    navigation: showNavigationBreaking,
    breakpoints: {
      0: {
        slidesPerView: 1
      },

      768: {
        slidesPerView: 2
      },

      992: {
        slidesPerView: 2
      },
      1200: {
        slidesPerView: 3
      }
    },
    autoplay: true,
    // Add slide change event handler
    onSlideChange: (swiper) => {
      setCurrentBreakingSlide(swiper.activeIndex)
    }
  }

  // Handle window resize for responsive slides per view calculation
  useEffect(() => {
    const handleResize = () => {
      setWindowWidth(window.innerWidth);
    };

    // Set initial width
    if (typeof window !== 'undefined') {
      setWindowWidth(window.innerWidth);
    }

    // Add event listener
    window.addEventListener('resize', handleResize);

    // Cleanup
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Remove the old sliderRef and update navigation handlers
  const handleNewsPrev = useCallback(() => {
    if (!newsSliderRef.current) return;
    newsSliderRef.current.swiper.slidePrev();
  }, []);

  const handleNewsNext = useCallback(() => {
    if (!newsSliderRef.current) return;
    newsSliderRef.current.swiper.slideNext();
  }, []);

  const handleVideoPrev = useCallback(() => {
    if (!videoSliderRef.current) return;
    videoSliderRef.current.swiper.slidePrev();
  }, []);

  const handleVideoNext = useCallback(() => {
    if (!videoSliderRef.current) return;
    videoSliderRef.current.swiper.slideNext();
  }, []);

  const handleBreakingPrev = useCallback(() => {
    if (!breakingSliderRef.current) return;
    breakingSliderRef.current.swiper.slidePrev();
  }, []);

  const handleBreakingNext = useCallback(() => {
    if (!breakingSliderRef.current) return;
    breakingSliderRef.current.swiper.slideNext();
  }, []);

  // Helper functions to check if buttons should be disabled
  // Get current slides per view based on screen size
  const getCurrentSlidesPerView = () => {
    if (windowWidth >= 1200) return 3;
    if (windowWidth >= 992) return 2;
    if (windowWidth >= 768) return 2;
    return 1;
  };

  const isNewsPrevDisabled = () => currentNewsSlide === 0;
  const isNewsNextDisabled = () => {
    const slidesPerView = getCurrentSlidesPerView();
    // Calculate the maximum slide index that can be reached
    const maxSlideIndex = Math.max(0, Data.news?.length - Math.ceil(slidesPerView));
    return currentNewsSlide >= maxSlideIndex;
  };

  const isVideoPrevDisabled = () => currentVideoSlide === 0;
  const isVideoNextDisabled = () => {
    const slidesPerView = getCurrentSlidesPerView();
    const maxSlideIndex = Math.max(0, Data.videos?.length - Math.ceil(slidesPerView));
    return currentVideoSlide >= maxSlideIndex;
  };

  const isBreakingPrevDisabled = () => currentBreakingSlide === 0;
  const isBreakingNextDisabled = () => {
    const slidesPerView = getCurrentSlidesPerView();
    const maxSlideIndex = Math.max(0, Data.breaking_news?.length - Math.ceil(slidesPerView));
    return currentBreakingSlide >= maxSlideIndex;
  };

  return (
    Data &&
    <>
      {/* ad spaces */}
      {Data.ad_spaces && Data.id == Data.ad_spaces.ad_featured_section_id ? (
        <div className='container'>
          <AdSpace ad_url={Data.ad_spaces.ad_url} ad_img={Data.ad_spaces.web_ad_image} style_web={'five'} />
        </div>
      ) : null}

      {/* videoNewsSect starts from here  */}
      {
        Data.videos && Data.videos?.length > 0 &&
        <div className="relative styleFiveSwiper commonBg overflow-hidden">
          <div className='container p-4'>
            <div className="grid grid-cols-1 md:grid-cols-6 gap-6 items-center py-12">

              <div className="md:col-span-2 bg-gray-900 text-white p-6 rounded-[16px] relative overflow-hidden h-full flexCenter">
                <Image src={earthImg} alt="Earth" className="absolute inset-0 w-full h-full object-cover opacity-50" onError={placeholderImage} loading='lazy' />
                <div className="relative z-[1] md:ml-2 xl:ml-14">
                  <h6 className="text-[30px] sm:text-[42px] font-medium mb-4">{Data?.title}</h6>
                  <Link
                    href={{ pathname: `/${currLangCode}/view-all/${Data?.slug}`, query: { language_id: currentLanguage?.id } }}
                    title={translate('viewall')}
                    className="commonBtn text-[18px] sm:text-[20px] !font-medium">
                    {translate('viewall')}
                  </Link>
                </div>
              </div>

              <div className="md:col-span-4 ">
                <Swiper
                  ref={videoSliderRef}
                  key={getDirection()}
                  {...swiperOptionVideo}
                  pagination={{
                    clickable: false,
                  }}
                  autoplay={{ delay: 3000 }}
                  modules={[Autoplay]}
                  className="tech-swiper !pt-20 !pb-2"
                >
                  {
                    Data?.videos?.map((element, index) => (
                      <SwiperSlide key={index}>
                        <StyleFiveCard element={element} videoNewsCard={true} />
                      </SwiperSlide>
                    ))
                  }
                </Swiper>
              </div>
            </div>

            {
              Data && Data.videos?.length > 3 &&
              <div className="navigations flexCenter lg:w-[135%] gap-4 pb-8">

                <div className={`swiper-button-prev !px-2 !rounded-[8px] commonBtn ${isVideoPrevDisabled() ? 'opacity-50 !cursor-not-allowed after:!w-0 hover:!after:bg-transparent' : ''}`} onClick={handleVideoPrev} style={{ pointerEvents: isVideoPrevDisabled() ? 'none' : 'auto' }}>
                  <span><FaAngleLeft color='white' className='rtl:rotate-180' size={28} /></span>
                </div>
                <div className={`swiper-button-next !px-2 !rounded-[8px] commonBtn ${isVideoNextDisabled() ? 'opacity-50 !cursor-not-allowed after:!w-0 hover:!after:bg-transparent' : ''}`} onClick={handleVideoNext}>
                  <span><FaAngleRight color='white' className='rtl:rotate-180' size={28} /></span>
                </div>

              </div>
            }
          </div>
        </div>

      }
      {/* videoNewsSect ends here  */}


      {/* newsSect starts from here  */}
      {
        Data && Data.news?.length &&
        <div className="relative styleFiveSwiper commonBg overflow-hidden">
          <div className='container p-4'>
            <div className="grid grid-cols-1 md:grid-cols-6 gap-6 items-center py-12">

              <div className="md:col-span-2 bg-gray-900 text-white p-6 rounded-[16px] relative overflow-hidden h-full flexCenter">
                <Image src={earthImg} alt="Earth" className="absolute inset-0 w-full h-full object-cover opacity-50" onError={placeholderImage} loading='lazy'/>
                <div className="relative z-[1] md:ml-2 xl:ml-14">
                  <h2 className="text-[30px] sm:text-[42px] font-medium mb-4">{Data?.title}</h2>
                  <Link
                    href={{ pathname: `/${currLangCode}/view-all/${Data?.slug}`, query: { language_id: currentLanguage?.id } }}
                    title={translate('viewall')}
                    className="commonBtn text-[18px] sm:text-[20px] !font-medium">
                    {translate('viewall')}
                  </Link>
                </div>
              </div>

              <div className="md:col-span-4 ">
                <Swiper
                  ref={newsSliderRef}
                  key={getDirection()}
                  {...swiperOption}
                  pagination={{
                    clickable: false,
                  }}
                  autoplay={{ delay: 3000 }}
                  modules={[Autoplay]}
                  className="tech-swiper !pt-20 !pb-2"
                >
                  {
                    Data?.news?.map((element, index) => (
                      <SwiperSlide key={index}>
                        <StyleFiveCard element={element} />
                      </SwiperSlide>
                    ))
                  }
                </Swiper>
              </div>
            </div>
            {
              Data && Data.news?.length > 3 &&
              <div className="navigations flexCenter lg:w-[135%] gap-4 pb-8">

                <div className={`swiper-button-prev !px-2 !rounded-lg commonBtn ${isNewsPrevDisabled() ? 'opacity-50 !cursor-not-allowed after:!w-0 hover:!after:bg-transparent' : ''}`} onClick={handleNewsPrev}>
                  <span><FaAngleLeft color='white' className='rtl:rotate-180' size={28} /></span>
                </div>
                <div className={`swiper-button-next !px-2 !rounded-lg commonBtn ${isNewsNextDisabled() ? 'opacity-50 !cursor-not-allowed after:!w-0 hover:!after:bg-transparent' : ''}`} onClick={handleNewsNext}>
                  <span><FaAngleRight color='white' className='rtl:rotate-180' size={28} /></span>
                </div>

              </div>
            }
          </div>
        </div>
      }
      {/* newsSect ends here  */}


      {/* breakingNewsSect starts from here  */}
      {
        Data && Data.breaking_news?.length &&
        <div className="relative styleFiveSwiper commonBg overflow-hidden"> 
          <div className='container p-4'>
            <div className="grid grid-cols-1 md:grid-cols-6 gap-6 items-center py-12">

              <div className="md:col-span-2 bg-gray-900 text-white p-6 rounded-[16px] relative overflow-hidden h-full flexCenter">
                <Image src={earthImg} alt="Earth" loading='lazy' className="absolute inset-0 w-full h-full object-cover opacity-50" onError={placeholderImage}/>
                <div className="relative z-[1] md:ml-2 xl:ml-14">
                  <h2 className="text-[30px] sm:text-[42px] font-medium mb-4">{Data?.title}</h2>
                  <Link
                    href={{ pathname: `/${currLangCode}/view-all/${Data?.slug}`, query: { language_id: currentLanguage?.id } }}
                    title={translate('viewall')}
                    className="commonBtn text-[18px] sm:text-[20px] !font-medium">
                    {translate('viewall')}
                  </Link>
                </div>
              </div>

              <div className="md:col-span-4 ">
                <Swiper
                  ref={breakingSliderRef}
                  key={getDirection()}
                  {...swiperOptionBreaking}
                  pagination={{
                    clickable: false,
                  }}
                  autoplay={{ delay: 3000 }}
                  modules={[Autoplay]}
                  className="tech-swiper !pt-20 !pb-2"
                >
                  {
                    Data?.breaking_news?.map((element, index) => (
                      <SwiperSlide key={index}>
                        <StyleFiveCard element={element} breakingNewsCard={true} />
                      </SwiperSlide>
                    ))
                  }
                </Swiper>
              </div>
            </div>
            {
              Data && Data.breaking_news?.length > 3 &&
              <div className="navigations flexCenter lg:w-[135%] gap-4 pb-8">

                <div className={`swiper-button-prev !px-2 !rounded-lg commonBtn ${isBreakingPrevDisabled() ? 'opacity-50 !cursor-not-allowed after:!w-0 hover:!after:bg-transparent' : ''}`} onClick={handleBreakingPrev}>
                  <span><FaAngleLeft color='white' className='rtl:rotate-180' size={28} /></span>
                </div>
                <div className={`swiper-button-next !px-2 !rounded-lg commonBtn ${isBreakingNextDisabled() ? 'opacity-50 !cursor-not-allowed after:!w-0 hover:!after:bg-transparent' : ''}`} onClick={handleBreakingNext}>
                  <span><FaAngleRight color='white' className='rtl:rotate-180' size={28} /></span>
                </div>

              </div>
            }
          </div>
        </div>
      }
      {/* breakingNewsSect ends here  */}


    </>
  );
};

export default StyleFive;