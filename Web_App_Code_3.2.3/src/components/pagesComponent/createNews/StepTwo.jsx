'use client'
import { translate } from '@/utils/helpers'
import React, { useState } from 'react'
import { BsRobot } from 'react-icons/bs'
import ReactQuill from 'react-quill'
import { toast } from 'react-hot-toast'

const StepTwo = ({ setStep, content, handleChangeContent, finalSubmit, aiPrompt, setAiPrompt, isGeneratingContent, generateAIContent }) => {
   

    return (
        <div className='flex flex-col gap-4'>
            <div className='flex items-center justify-between'>
                <h1 className="text-[18px] font-[600] textPrimary">{translate('createNewsLbl')}</h1>
                <h2 className='font-[500]'>{translate('step2of2Lbl')}</h2>
            </div>

            <div className='ai-assistant mb-3'>
                <div className='flex items-center justify-between mb-2'>
                    <input
                        type='text'
                        className='w-[80%] border borderColor commonRadius dark:text-black px-4 py-2 focus:outline-none'
                        placeholder={translate('enterPrompt')}
                        value={aiPrompt}
                        onChange={(e) => setAiPrompt(e.target.value)}
                    />
                    <button
                        onClick={generateAIContent}
                        disabled={isGeneratingContent || !aiPrompt}
                        className='commonBtn flexCenter text-sm'
                    >
                        {isGeneratingContent ? `${translate('generating')}` : <><BsRobot className="me-1" /> {translate('generate')}</>}
                    </button>
                </div>
                <span className="text-muted text-sm textPrimary">{translate('tryPrompt')}</span>
            </div>

            <div>
                <ReactQuill value={content} onChange={handleChangeContent} />
            </div>
            <div className='flex items-center gap-3'>
                <button className='commonBtn w-full text-[18px] font-[600]' onClick={() => setStep(1)}>{translate('back')}</button>
                <button className='commonBtn w-full text-[18px] font-[600]' onClick={e => finalSubmit(e)}>{translate('submitBtn')}</button>
            </div>
        </div>
    )
}

export default StepTwo