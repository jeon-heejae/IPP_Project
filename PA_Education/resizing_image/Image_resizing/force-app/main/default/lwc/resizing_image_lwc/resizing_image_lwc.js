import { LightningElement,track,api } from 'lwc';
import saveImg from '@salesforce/apex/imageUploadController.saveImage';

export default class Resizing_image_lwc extends LightningElement {
    @track SIZE_1MB=1024*1024; //1024*1024=1048576byte
    @track SIZE_250KB=1024*250; //1024*250=256000byte

    @track objPhoto = {
        fileTitle: '',
        fileContents: '',
        tempUrl: ''
    };
    @track isResizeComplete = false;
    @api recordId;


    handleFilesChange(event) {
        const files = event.target.files; // 파일 목록 가져오기
        if (files.length > 0) { // 파일이 하나 이상 선택된 경우
            const file = files[0]; // 첫 번째 파일 선택
            console.log('File selected:', file.name);
            console.log('File size: ', file.size);
            if (file.size > this.SIZE_1MB) { // 파일 크기가 1MB 초과
                console.log('Resizing ::');
                this.resizeImage(file, this.SIZE_250KB, 0.0, 0.5, 1.0); // 리사이즈 시작
            } else {
                console.log('No Resizing ::');
                this.doUploadImage(file,file);
            }
        } else {
            console.error('No file selected'); // 파일이 선택되지 않은 경우
        }
    }
    

    resizeImage(fileBlob, maxDeviation, low, middle, high) {
        console.log('resize start');
        const reader = new FileReader();
        var img = new Image();
        let fileBlobNew;
        let parent = this;


        // 1. FileReader로 파일 읽기
        reader.addEventListener("load", function () {
            img.src = reader.result; // 파일을 이미지로 로드
        }, false);
        reader.readAsDataURL(fileBlob); // 파일을 Base64로 변환
    
        // 2. 이미지가 로드된 후 리사이즈 작업 실행
        img.onload = function () {
            const canvas = document.createElement('canvas');
            const context = canvas.getContext("2d");
            let width = img.width;
            let height = img.height;
    
            // 리사이즈된 이미지 크기 설정
            canvas.width = Math.round(width * middle);
            canvas.height = Math.round(height * middle);
            console.log('Ratio  :: ' + middle);
            console.log('Before :: ' + width + 'x' + height);
            console.log('After  :: ' + canvas.width + 'x' + canvas.height);
    
            // 이미지 크기 조정 및 그리기
            context.scale(canvas.width / width, canvas.height / height);
            context.drawImage(img, 0, 0);
    
            // Blob 생성
            var dataUrl = canvas.toDataURL();
            var byteString = atob(dataUrl.split(',')[1]);
            var mimeString = dataUrl.split(',')[0].split(':')[1].split(';')[0];
            var ab = new ArrayBuffer(byteString.length);
            var ia = new Uint8Array(ab);
            for (var i = 0; i < byteString.length; i++) {
                ia[i] = byteString.charCodeAt(i);
            }
            fileBlobNew = new Blob([ab], { type: mimeString }); // 새로운 Blob 생성
    
            let fileSize = fileBlobNew.size; // 리사이즈된 파일 크기
            console.log('fileSize: ' + fileSize);
    
            // 3. 크기 비교 후 재귀 호출 또는 완료 처리
            if (Math.abs(fileSize - parent.SIZE_1MB) > maxDeviation) {
                console.log('compare');
                if (fileSize < (parent.SIZE_1MB - maxDeviation)) {
                    low = middle;
                } else if (fileSize > parent.SIZE_1MB) {
                    high = middle;
                }
                middle = (low + high) / 2; // 중간값 계산
                console.log('resizing..');
                parent.resizeImage(fileBlob, maxDeviation, low, middle, high); // 재귀 호출
            } else {
                parent.doUploadImage(fileBlob, fileBlobNew); // 리사이즈 완료
                console.log('complete');
            }
        };
    }
       

    doUploadImage(fileBlob, fileBlobNew) {
        let reader = new FileReader();
        let parent = this;
    
        reader.addEventListener("load", function () {
            let fileContents = reader.result;
            console.log('fileContents: '+fileContents);
            let fileMatching=fileContents.match(/,(.*)$/)[1];
            console.log('match: '+fileMatching);
            let base64 = 'base64,';
            let dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart); // Base64 데이터 추출
    
            parent.objPhoto.fileTitle = fileBlob.name;
            parent.objPhoto.fileContents = fileContents;
            parent.objPhoto.tempUrl = URL.createObjectURL(fileBlobNew); // 임시 URL 생성
            console.log(parent.objPhoto.fileTitle);
            console.log(parent.objPhoto.fileContents);
            console.log(parent.objPhoto.tempUrl);
    
            parent.isResizeComplete = true; // 리사이즈 완료

            // objPhoto 값 설정 후 saveImg 호출
            parent.saveImageToServer();
        }, false);
    
        reader.readAsDataURL(fileBlobNew); // 파일 읽기

    }

    saveImageToServer() {
        if (this.objPhoto.fileTitle && this.objPhoto.fileContents) {
            console.log('Saving image to server...');
            saveImg({
                parentId: this.recordId,
                fileName: this.objPhoto.fileTitle,
                base64Data: this.objPhoto.fileContents
            })
                .then((result) => {
                    if (result) {
                        console.log('저장 성공');
                    } else {
                        console.log('저장 실패');
                    }
                })
                .catch((error) => {
                    console.error('Error: ' + error);
                });
        } else {
            console.error('objPhoto에 데이터가 없습니다.');
        }
    }
    
}