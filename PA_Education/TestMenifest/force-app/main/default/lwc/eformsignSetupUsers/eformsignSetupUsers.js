/**
 * Created by hs.jung on 2024-05-29.
 */

import { LightningElement, wire, track } from 'lwc';
import getPermissionSets from '@salesforce/apex/EformsignSetupCtrl.getPermissionSets';
import getUsersAssignedToPermissionSet from '@salesforce/apex/EformsignSetupCtrl.getUsersAssignedToPermissionSet';
import getMembers from '@salesforce/apex/EformsignSetupCtrl.getEfsMembers';
import enrollEfsMember from '@salesforce/apex/EformsignSetupCtrl.enrollEfsMember';
import deleteEfsMember from '@salesforce/apex/EformsignSetupCtrl.deleteEfsMember';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const ENROLL_ACTION = 'Enroll';
const DELETE_ACTION = 'Delete';

export default class EformsignSetupUsers extends LightningElement {
    @track permissionSets;
    @track isModalOpen = false;
    @track isLoading = true;
    showLoading() {
        this.isLoading = true;
    }
    hideLoading() {
        this.isLoading = false;
    }

    @wire(getPermissionSets)
    wiredPermissionSets({ error, data }) {
        if (data) {
            this.permissionSets = data.map(permSet => {
                return {
                    Label: permSet.Label + ' 관리',
                    url: `${this.domainUrl}/lightning/setup/PermSets/${permSet.Id}/PermissionSetAssignment/home`
                };
            });
        } else if (error) {
            console.error(error);
        }
    }

    get domainUrl() {
        return window.location.origin;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    connectedCallback() {
        this.getEfsMembers();
    }

    navigateToUrl(event) {
        const url = event.target.dataset.url;
        window.open(url, '_blank');
    }

    dynamicEfsActions(row, doneCallback){
        console.log('row', JSON.stringify(row));
        let rowActions = [
            {label: '삭제', name: DELETE_ACTION},
        ];
        let emptyRowActions = [
            {label: '-', value: '-'},
        ];

        // 대표 관리자 수정/삭제 불가
        const isAdmin = row.Role.includes('admin');
        if (isAdmin) {
            return doneCallback(emptyRowActions);
        }

        // 비활성화 유저 수정/삭제 불가
        if (!row.Enabled) {
            return doneCallback(emptyRowActions);
        }

        return doneCallback(rowActions);
    }

    // start: eformsign 멤버 리스트 관련 로직
    efsMemberColumns = [
        { label: 'id', fieldName: 'Id', initialWidth: 200 },
        { label: '이름', fieldName: 'Name', initialWidth: 70 },
        { label: '생성일', fieldName: 'CreateDate' },
        { label: '활성화', fieldName: 'Enabled' },
        { label: '역할', fieldName: 'Role' },
        { type: 'action',
            typeAttributes: {
                rowActions: this.dynamicEfsActions.bind(this)
            }
        }
    ];
    @track efsMembers = [];
    efsMemberIds;
    getEfsMembers() {
        this.showLoading();

        getMembers()
            .then(result => {
                if (!result.isSuccess) {
                    this.showToast('멤버 조회 요청 실패', result.message, 'error');
                    return;
                }
                this.setEfsMembers(result.data)
                this.showToast('eformsign 등록 멤버 조회 완료', '', 'success');

                this.hideLoading();
            })
            .catch(error => {
                this.showToast('멤버 조회 요청 실패', error, 'error');
            })
    }

    COMMA = ', ';
    setEfsMembers(data) {
        const members = data.members;

        if (!members.length) {
            return;
        }

        // 멤버 리스트 생성
        const result = members.map((m) => {
            return {
                Id: m.id,
                Name: m.name,
                CreateDate: new Date(m.create_date).toLocaleString(),
                Enabled: m.enabled,
                Role: m.role.join(this.COMMA),
            };
        });
        this.efsMembers = result;
        // console.log(JSON.stringify(result, null, 2));

        // 멤버 Id(Email)로 중복 제거 리스트 생성
        const resultSet = new Set();
        result.forEach(m => resultSet.add(m.Id));
        this.efsMemberIds = resultSet;
    }

    refreshEfsMembers() {
        this.getEfsMembers();
    }

    /*
    {
    "data": {
        "members":
        [
            {
                "id": "gim@mz.co.kr",
                "account_id": "gim@mz.co.kr",
                "name": "김형주",
                "create_date": 1692849495932,
                "enabled": true,
                "isRefused": false,
                "isExpired": false,
                "isInvited": false,
                "isWithdrawal": false,
                "contact": {
                "number": "",
                "tel": "",
                "email": "",
                "country_id": ""
                },
                "role": [
                "admin",
                "company_manager",
                "template_manager",
                "member"
                ],
                "group": [],
                "fields": [],
                "deleted": false
            },
            {
                "id": "pyj@forcs.com",
                "account_id": "pyj@forcs.com",
                "name": "박윤정",
                "department": "",
                "position": "",
                "create_date": 1698127501581,
                "enabled": true,
                "isRefused": false,
                "isExpired": false,
                "isInvited": false,
                "isWithdrawal": false,
                "contact": {
                "number": "1047197856",
                "tel": "",
                "email": "",
                "country_id": "+82"
                },
                "role": [
                "member"
                ],
                "group": [],
                "fields": [],
                "deleted": false
            },
            {
                "id": "ben@mz.co.kr",
                "account_id": "ben@mz.co.kr",
                "name": "이명현",
                "department": "",
                "position": "",
                "create_date": 1698719212086,
                "enabled": true,
                "isRefused": false,
                "isExpired": false,
                "isInvited": false,
                "isWithdrawal": false,
                "contact": {
                "number": "",
                "tel": "",
                "email": "",
                "country_id": ""
                },
                "role": [
                "member",
                "template_manager",
                "company_manager",
                "document_manager"
                ],
                "group": [],
                "fields": [],
                "deleted": false
            }
        ]
    },
    "isSuccess": true,
    "message": "Success"
    }
    */

    handleEfsMemberRowAction(event) {
        console.log(JSON.stringify(event, null, 2));
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('DELETE_ACTION', DELETE_ACTION);
        switch (actionName) {
            case DELETE_ACTION:
                this.deleteMember(row);
                break;
            default:
        }
    }

    deleteMember(row) {
        this.showLoading();

        deleteEfsMember({
            email: row.Id,
        })
            .then(result => {
                console.log('deleteEfsMember result>>', JSON.stringify(result, null, 2));
                if (!result.isSuccess) {
                    this.showToast('멤버 삭제 실패', result.message, 'error');
                    return;
                }
                this.showToast('eformsign 삭제 완료', result, 'success');
            })
            .catch(error => {
                this.showToast('멤버 삭제 실패', error, 'error');
            })
            .finally(() => {
                this.refreshEfsMembers()
            });
    }
    // end: eformsign 멤버 리스트 관련 로직


    // start: 모달 관련 로직
    assignedUserColumns = [
        { label: 'Name', fieldName: 'Name', sortable: true },
        { label: '이폼사인ID(이메일)', fieldName: 'Email' },
        // { label: '활성화', fieldName: 'IsActive' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: '등록', name: ENROLL_ACTION },
                ]
            }
        }
    ];
    @track usersNeedToEnroll = [];
    getAssignedUsers() {
        this.showLoading();

        this.resetUsers();
        getUsersAssignedToPermissionSet()
            .then(result => {
                const users = result.map((row) => row.Assignee);
                // console.log('users\n', JSON.stringify(users, null, 2));

                this.usersNeedToEnroll = users.filter((u) => !this.efsMemberIds.has(u.Email));
                // console.log('this.usersNeedToEnroll\n', JSON.stringify(this.usersNeedToEnroll, null, 2));

                this.showToast('조회 완료', 'eformsign 미등록 세일즈포스 유저 조회 완료', 'success');
                this.isModalOpen = true;
            })
            .catch(error => {
                console.log('error', JSON.stringify(error, null, 2));
                this.showToast('조회 실패', '멤버 조회 실패', 'error');
            })
            .finally(() => {
                this.hideLoading();
            });
    }

    closeModal() {
        this.isModalOpen = false;
        this.resetUsers();
    }

    resetUsers() {
        this.usersNeedToEnroll = [];
    }

    handleUserRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case ENROLL_ACTION:
                this.enrollMember(row);
                break;
            default:
        }
    }

    enrollMember(row) {
        this.showLoading();
        this.closeModal();

        enrollEfsMember({
            email: row.Email,
            name: row.Name,
        })
            .then(result => {
                console.log(JSON.stringify(result, null, 2));
                if (!result.isSuccess) {
                    this.showToast('멤버 등록 실패', result.message, 'error');
                    return;
                }
                // {ErrorMessage=This ID is already taken., code=4000135}
                this.showToast('eformsign 등록 완료', result, 'success');
            })
            .catch(error => {
                this.showToast('멤버 등록 실패', error, 'error');
            })
            .finally(() => {
                this.refreshEfsMembers()
            });
    }
    // end: 모달 관련 로직

    // getSelectedUsers(event) {
    //     const selectedRows = event.detail.selectedRows;
    //     // Display that fieldName of the selected rows
    //     for (let i = 0; i < selectedRows.length; i++) {
    //         console.log(selectedRows[i].Name);
    //     }
    // }
}