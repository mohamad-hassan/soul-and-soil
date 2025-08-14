'use client'
import React, { useState, useEffect } from 'react'
import Breadcrumb from '@/components/breadcrumb/Breadcrumb'
import { useRouter } from 'next/router'
import { FiCalendar } from 'react-icons/fi';
import { AiOutlineLike, AiFillLike } from 'react-icons/ai';
import RelatedNewSections from '@/components/relatedNews/RelatedNewSections'
import { useSelector } from 'react-redux'
import { settingsSelector } from '@/components/store/reducers/settingsReducer'
import { getVideoNewsApi, setLikeDisLikeApi } from '@/utils/api/api'
import { isLogin, NoDataFound, placeholderImage, translate } from '@/utils/helpers'
import VideoPlayer from '../../commonComponents/videoplayer/HLSPlayer.jsx'
import toast from 'react-hot-toast'
import { userDataSelector } from '@/components/store/reducers/userReducer'
import DetailPageSkeleton from '@/components/skeletons/DetailPageSkeleton'
import OpenInAppPopUp from '@/components/commonComponents/OpenInAppPopUp'
import { setLoginModalState } from '@/components/store/reducers/helperReducer'
import Layout from '@/components/layout/Layout'
import { currentLanguageSelector } from '@/components/store/reducers/languageReducer';
import ReactPlayer from 'react-player';
import MediaShare from '@/components/SocialMediaShares/MediaShare'


const VideoDetails = () => {

    const router = useRouter();

    const slug = router?.query?.slug;
    const isShare = router?.query?.share;
    const routerLanguageId = router?.query?.language_id;

    const settingsData = useSelector(settingsSelector)
    const currentLanguage = useSelector(currentLanguageSelector)

    const [like, setLike] = useState(false);

    const [loading, setLoading] = useState(true)
    const [data, setData] = useState([])

    const [likeNewsIncreament, setLikeNewIncreament] = useState(false)
    const [likeNews, setLikeNews] = useState(false)

    const [IsOpenInApp, setIsOpenInApp] = useState(false);
    const [windowWidth, setWindowWidth] = useState(0);

    // Safe window check
    useEffect(() => {
        // Only run on client side
        if (typeof window !== 'undefined') {
            // Set initial width
            setWindowWidth(window.innerWidth);

            // Add event listener to update width on resize
            const handleResize = () => {
                setWindowWidth(window.innerWidth);
            };

            window.addEventListener('resize', handleResize);

            // Clean up
            return () => window.removeEventListener('resize', handleResize);
        }
    }, []);

    // Now use windowWidth state instead of directly accessing window.innerWidth
    useEffect(() => {
        if (isShare && windowWidth <= 768) {
            setIsOpenInApp(true);
        } else {
            setIsOpenInApp(false);
        }
    }, [windowWidth, isShare]);

    const userData = useSelector(userDataSelector)

    const currentUrL = typeof window !== 'undefined'
        ? `${process.env.NEXT_PUBLIC_WEB_URL}${router?.asPath}&share=true`
        : '';

    const decodedURL = currentUrL ? decodeURI(currentUrL) : '';


    let userName = ''

    const checkUserData = userData => {
        if (userData?.data && userData?.data?.name !== '') {
            return (userName = userData?.data?.name)
        } else if (userData?.data && userData?.data?.email !== '') {
            return (userName = userData?.data?.email)
        } else if (userData?.data && (userData?.data?.mobile !== null || userData?.data?.mobile !== '')) {
            return (userName = userData?.data?.mobile)
        }
    }

    const getNewsDetails = async () => {
        try {
            setLoading(true)
            const { data } = await getVideoNewsApi.getVideoNews({
                slug: slug,
                language_id: routerLanguageId
            });

            if (!data?.error) {

                if (data?.data?.[0]?.like === 0) {
                    setLike(false);
                } else {
                    setLike(true);
                }

                setData(data)
                setLoading(false)
            }
            else {
                console.log('error =>', data?.message)
                setData([])
                setLoading(false)
            }

        } catch (error) {
            console.error('Error:', error);
            setLoading(false)
            setData([])
        }
    };

    useEffect(() => {
        if (routerLanguageId) {
            getNewsDetails()
        }
        // console.log('slug', slug);

    }, [currentLanguage, slug, routerLanguageId]);


    const handleLikeNews = () => {
        if (isLogin()) {
            setLikeDislikeData(data && data?.data?.[0]?.id)
        }
        else {
            setLoginModalState({ openModal: true })
            toast.error(translate('loginFirst'))
            setTimeout(() => {
                setLoginModalState({ openModal: false })
            }, 2000);
        }
    }

    const setLikeDislikeData = async (id) => {
        try {
            const { data } = await setLikeDisLikeApi.setLikeDisLike({
                news_id: id,
                status: like ? 0 : 1,
            });

            if (!data?.error) {
                // getNewsDetails()
                setLikeNewIncreament(!likeNewsIncreament)
                setLike(!like)
            }
            else {
                console.log('like error =>', data?.message)
            }
            // toast.success(response?.data?.message);

        } catch (error) {
            console.error('Error:', error);
        }
    };


    // Function to check if the URL has an HLS or M3U8 extension
    const isHLSUrl = url => {
        return url?.endsWith('.m3u8')
    }

    // Function to convert YouTube URLs to proper embed format
    const getYoutubeEmbedUrl = (url) => {
        if (!url) return url;

        // Handle YouTube Shorts
        if (url.includes('youtube.com/shorts/')) {
            const videoId = url.split('/shorts/')[1]?.split('?')[0];
            if (videoId) {
                return `https://www.youtube.com/embed/${videoId}`;
            }
        }

        // Handle regular YouTube URLs
        if (url.includes('youtube.com/watch')) {
            const videoId = new URL(url).searchParams.get('v');
            if (videoId) {
                return `https://www.youtube.com/embed/${videoId}`;
            }
        }

        // Handle youtu.be shortened URLs
        if (url.includes('youtu.be/')) {
            const videoId = url.split('youtu.be/')[1]?.split('?')[0];
            if (videoId) {
                return `https://www.youtube.com/embed/${videoId}`;
            }
        }

        return url;
    }

    // Check if URL is from YouTube
    const isYoutubeUrl = (url) => {
        return url && (
            url.includes('youtube.com') ||
            url.includes('youtu.be') ||
            url.includes('youtube-nocookie.com')
        );
    }

    // Determine correct video player to use
    const renderVideoPlayer = (url, type_url) => {
        if (isHLSUrl(url)) {
            return <VideoPlayer url={url} />;
        }

        if (isYoutubeUrl(url)) {
            // Use iframe with proper YouTube embed URL
            const embedUrl = getYoutubeEmbedUrl(url);
            return (
                <iframe
                    className='youtube_player max-[575px]:h-[300px] rounded-2xl'
                    src={embedUrl}
                    width='100%'
                    height='500px'
                    frameBorder='0'
                    allowFullScreen
                    allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
                />
            );
        }

        if (type_url === 'video_other' || type_url === 'url_other') {
            // For non-YouTube external URLs
            // Note: Some sites still won't allow embedding
            return (
                <iframe
                    className='video_other_url max-[575px]:h-[300px] rounded-2xl'
                    allow='autoplay'
                    frameBorder='0'
                    width='100%'
                    allowFullScreen
                    src={url}
                    onError={placeholderImage}
                    height='500px'
                />
            );
        }

        // Default to ReactPlayer for all other cases
        return <ReactPlayer width='100%' height='500px' url={url} controls={true} className='max-[575px]:h-[300px] rounded-2xl' />;
    }


    useEffect(() => {
    }, [likeNews])

    return (
        <Layout>
            <section className='detailPage'>
                {
                    loading ?
                        <DetailPageSkeleton />
                        :
                        data && data?.data?.length > 0 ?
                            <>
                                {
                                    <Breadcrumb secondElement={translate('videoDetails')} thirdElement={data && data?.data[0]?.title} />
                                }

                                <section className='container detailPage commonMT'>
                                    <div className="grid grid-cols-12 gap-y-10 lg:gap-8">
                                        <div className="col-span-12 lg:col-span-8">
                                            <div className='flex flex-col gap-8'>

                                                <div className='relative'>
                                                    {
                                                        data && data?.data[0]?.content_value &&
                                                        renderVideoPlayer(data && data?.data[0]?.content_value, data && data?.data[0]?.content_type)
                                                    }
                                                </div>

                                                <div>
                                                    {
                                                        data && data?.data[0]?.category_name &&
                                                        <span className='categoryTag'>{data && data?.data[0]?.category_name}</span>
                                                    }
                                                    <h2 className='text-[22px] md:text-[34px] lg:text-[46px] font-[700] capitalize textPrimary mt-2'>
                                                        {data && data?.data[0]?.title}
                                                    </h2>
                                                </div>

                                                <div className='flex items-center justify-between flex-wrap gap-6 border-y borderColor py-4 sm:py-6'>
                                                    <div className='flex items-center gap-4 sm:gap-8 flex-wrap'>
                                                        {
                                                            <>
                                                                {
                                                                    data && data?.data[0]?.published_date &&
                                                                    <div className='flex items-center gap-1 textPrimary font-[600]'>
                                                                        <FiCalendar size={18} />
                                                                        <span>{new Date(data && data?.data[0]?.published_date).toLocaleString('en-us', {
                                                                            day: 'numeric',
                                                                            month: 'short',
                                                                            year: 'numeric'
                                                                        })}</span>
                                                                    </div>
                                                                }
                                                                {
                                                                    data && data?.data[0]?.source_type !== 'breaking_news' &&
                                                                    <div className='flex items-center gap-1 textPrimary font-[600]'>
                                                                        <span className='cursor-pointer font-[600]' onClick={() => handleLikeNews()}>
                                                                            {
                                                                                like && isLogin() ?
                                                                                    <span>
                                                                                        <AiFillLike size={23} onClick={() => setLikeNews(false)} />
                                                                                    </span>
                                                                                    :
                                                                                    <span>
                                                                                        <AiOutlineLike size={23} onClick={() => setLikeNews(true)} />
                                                                                    </span>
                                                                            }
                                                                        </span>
                                                                        {
                                                                            likeNewsIncreament && likeNews && like ?
                                                                                <span>{data && data?.data[0]?.total_like + 1} {translate('likes')}</span>
                                                                                :
                                                                                <span>{data && data?.data[0]?.total_like} {translate('likes')}</span>
                                                                        }
                                                                    </div>
                                                                }
                                                            </>
                                                        }
                                                    </div>

                                                    <MediaShare url={decodedURL} title={`${data?.data[0]?.title} - ${settingsData && settingsData?.data?.web_setting?.web_name}`} hashtag={`${settingsData && settingsData?.data?.web_setting?.web_name}`} />

                                                </div>
                                            </div>
                                        </div>

                                        <div className="col-span-12 lg:col-span-4 flex flex-col gap-6">
                                            {
                                                <>
                                                    {
                                                        data && data?.data[0]?.category_id &&
                                                        <RelatedNewSections newsSlug={slug} categorySlug={data && data?.data[0]?.category_slug} categoryId={data && data?.data[0]?.category_id} videoNewsPage={true}
                                                        />
                                                    }
                                                </>
                                            }
                                        </div>
                                    </div>
                                </section>
                            </>
                            :
                            <NoDataFound />
                }
                <OpenInAppPopUp IsOpenInApp={IsOpenInApp} OnHide={() => setIsOpenInApp(false)} />
            </section>
        </Layout>
    )
}

export default VideoDetails