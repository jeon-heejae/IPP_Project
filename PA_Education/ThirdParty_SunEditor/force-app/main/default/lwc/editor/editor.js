import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SunEditorJS from '@salesforce/resourceUrl/SunEditor2';
import getSunEditorContent from '@salesforce/apex/sunEditorController.getSunEditor';
import saveSunEditorContent from '@salesforce/apex/sunEditorController.doSaveRichText';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Editor extends LightningElement {
    @api recordId; // Object record ID
    editorInstance;

    renderedCallback() {
        if (this.editorInstance) {
            return;
        }

        Promise.all([
            loadScript(this, SunEditorJS + '/suneditor241206/dist/suneditor.min.js'),
            loadStyle(this, SunEditorJS + '/suneditor241206/dist/css/suneditor.min.css')
        ])
            .then(() => {
                this.initializeEditor();
            })
            .catch((error) => {
                console.error('Failed to load SunEditor', error);
            });
    }

    initializeEditor() {
        const container = this.template.querySelector('.editor-container');

        this.editorInstance = SUNEDITOR.create(container, {
            buttonList: [
                ['bold', 'italic', 'underline', 'strike'], 
                ['font', 'fontSize', 'formatBlock'], 
                ['align', 'list', 'table'], 
                ['link', 'image', 'video'], 
                ['codeView'],
                ['fontColor'],
                ['save', 'template']
            ],
            // attributesWhitelist: {
            //     img: 'src|alt|style|width|height' // img 태그에 허용할 속성 설정
            // },
            height: 600,
            imageWidth: 200, // 이미지의 기본 너비
            imageHeight: 200
        });

        this.handleLoad();
    }

    handleSave() {
        if (this.editorInstance) {
            const content = this.editorInstance.getContents();
            saveSunEditorContent({ fRecordId: this.recordId, fStrRichText:content })
                .then(() => {
                    this.showToast('Success', 'Content saved successfully', 'success');
                })
                .catch((error) => {
                    console.error('Error saving content', error);
                    this.showToast('Error', 'Failed to save content', 'error');
                });
        }
    }

    handleLoad() {
        console.log('recordId: '+this.recordId);
        getSunEditorContent({ fRecordId: this.recordId })
            .then((content) => {
                if (this.editorInstance) {
                    console.log('content: '+content);
                    this.editorInstance.setContents(content || '');
                }
            })
            .catch((error) => {
                console.error('Error loading content', error);
                this.showToast('Error', 'Failed to load content', 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}
