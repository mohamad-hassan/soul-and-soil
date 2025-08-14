'use client'
import VideoPlayerModal from '@/components/commonComponents/videoplayer/VideoPlayerModal';
import VideoPlayIcon from '@/components/commonComponents/VideoPlayIcon';
import { currentLangCode, placeholderImage, translate } from '@/utils/helpers';
import Image from 'next/image';
import Link from 'next/link';
import { LuCalendarDays } from 'react-icons/lu';

const StyleThreeCardOne = ({ Data, breakingNewsCard, videoNewsCard }) => {

    const currLangCode = currentLangCode();

    return (
        Data && !videoNewsCard ? <Link href={{ pathname: breakingNewsCard ? `/${currLangCode}/breaking-news/${Data?.slug}` : `/${currLangCode}/news/${Data?.slug}`, query: { language_id: Data?.language_id } }} title='detail-page'>
            <div className="group relative overflow-hidden commonRadius h-auto">
                <Image src={Data?.image} height={0} width={0} alt='img' loading='lazy' className={`lg:h-[520px] w-full object-cover commonRadius`} onError={placeholderImage} />
                <div className='text-white  mt-6 flex flex-col gap-0'>
                    <div className='absolute top-[20px] left-[20px]'>
                        {
                            Data?.category_name &&
                            <span className='categoryTag'>{Data?.category_name}</span>

                        }
                    </div>
                    {
                        Data?.date &&
                        <span className='flex items-center gap-2 textPrimary font-[500]'><LuCalendarDays size={20} />{new Date(Data?.date).toLocaleString('en-us', {
                            day: 'numeric',
                            month: 'short',
                            year: 'numeric'
                        })}</span>
                    }
                    <h3 className={`text-[18px] md:text-[24px] lg:text-[30px] font-[700] line-clamp-2 textPrimary`}>{Data?.title}</h3>
                </div>
            </div>
        </Link> :
            Data &&
            <div>
                <div className="group relative overflow-hidden commonRadius h-auto">
                    <div className='relative'>
                        <Image src={Data?.image} height={0} width={0} alt='img' loading='lazy' className={`lg:h-[520px] w-full object-cover commonRadius`} onError={placeholderImage} />
                        {
                            videoNewsCard && Data?.content_value &&
                            <Link href={{ pathname: `/${currLangCode}/video-news/${Data?.slug}`, query: { language_id: Data?.language_id } }} title='detail-page'>
                                <VideoPlayIcon videoSect={videoNewsCard} keyboard={false} url={Data?.content_value} type_url={Data?.content_type} />
                            </Link>
                        }
                    </div>
                    <div className='text-white  mt-6 flex flex-col'>
                        {
                            Data?.category_name &&
                            <div className='absolute top-[20px] left-[20px]'>
                                <span className='categoryTag'>{Data?.category_name}</span>
                            </div>
                        }
                        {
                            Data?.date &&
                            <span className='flex items-center gap-2 textPrimary font-[500]'><LuCalendarDays size={20} />{new Date(Data?.date).toLocaleString('en-us', {
                                day: 'numeric',
                                month: 'short',
                                year: 'numeric'
                            })}</span>
                        }

                        <h3 className={`text-[18px] md:text-[24px] lg:text-[30px] font-[700] line-clamp-2 textPrimary`}>{Data?.title}</h3>
                    </div>

                </div>
            </div>

    );
};

export default StyleThreeCardOne;
