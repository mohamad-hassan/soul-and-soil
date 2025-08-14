import Link from 'next/link'
import React from 'react'
import { useSelector } from 'react-redux'
import { currentLanguageSelector } from '../store/reducers/languageReducer'
import { translate } from '@/utils/helpers'
import { FaAngleLeft, FaAngleRight, FaArrowRightLong } from 'react-icons/fa6'

const StylesTitleDiv = ({ title, desc, link, styleSix, handlePrev, handleNext, isPrevDisabled, isNextDisabled }) => {

    const currentLanguage = useSelector(currentLanguageSelector)

    return (
        <div className='flex items-center justify-between flex-wrap mb-4 sm:mb-6 gap-3 sm:gap-2 lg:grid lg:grid-cols-12'>
            <div className='lg:col-span-9 flex flex-col gap-2'>
                <h1 className='textPrimary text-[18px] sm:text-[20px] md:text-[24px] font-[700]'>{title}</h1>
                <h2 className='textSecondary font-[500] md:text-[18px]'>{desc}</h2>
            </div>

            {
                !styleSix &&
                <div className='lg:col-span-3 lg:flex lg:items-center lg:justify-end'>
                    <Link href={{ pathname: link, query: { language_id: currentLanguage?.id } }} title={translate('viewMore')}>
                        <button className='flex items-center gap-2 border borderColor bg-transparent hover:hoverBg transition-all duration-300 hover:text-white rounded-[6px] textPrimary font-[700] py-[6px] px-[12px] md:py-[10px] md:px-[25px] md:text-[18px]'>{translate('viewMore')} <FaArrowRightLong className='mt-[2px] rtl:rotate-180' /></button>
                    </Link>
                </div>
            }
            {
                styleSix &&
                <div className="lg:col-span-3 flex lg:items-center lg:justify-end gap-3 sm:gap-4">

                    <div 
                        className={`swiper-button-prev !px-2 !rounded-[8px] commonBtn styleSixSwiperBtn ${isPrevDisabled ? 'opacity-50 !cursor-not-allowed after:!w-0 hover:!after:bg-transparent' : 'cursor-pointer'}`} 
                        onClick={!isPrevDisabled ? handlePrev : undefined}
                    >
                        <span><FaAngleLeft color='white' className='rtl:rotate-180' size={28} /></span>
                    </div>
                    <div 
                        className={`swiper-button-next !px-2 !rounded-[8px] commonBtn styleSixSwiperBtn ${isNextDisabled ? 'opacity-50 !cursor-not-allowed after:!w-0 hover:!after:bg-transparent' : 'cursor-pointer'}`} 
                        onClick={!isNextDisabled ? handleNext : undefined}
                    >
                        <span><FaAngleRight color='white' className='rtl:rotate-180' size={28} /></span>
                    </div>
                </div>
            }
        </div>
    )
}

export default StylesTitleDiv