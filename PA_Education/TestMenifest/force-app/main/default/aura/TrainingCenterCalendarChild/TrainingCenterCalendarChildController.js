({
    /**
     * @description render calendar
     */
    renderCalendar : function(component, event, helper) {
        console.log('renderCalendar');
        var eventsMap = component.get("v.events");
        var eventArray = [];

        if(component.get('v.sObjectName') != 'Event'){
            //when click search btn
            $('#calendar').fullCalendar('removeEvents');
            $.each(eventsMap, function(index, value){
                var newEvent2 = {
                    id : value.Id,
                    title : value.title,
                    start : moment(value.startDateTime),
                    allDay: true,
                    description : value.description,
                    owner : value.owner,
                    backgroundColor : value.backgroundColor
                }
                eventArray.push(newEvent2);
            });
            $('#calendar').fullCalendar('addEventSource', eventArray);
            $('#calendar').fullCalendar('refetchEvents');
            console.log(component.get("v.DateNextMonth"));
            $('#calendar').fullCalendar('gotoDate', component.get("v.DateNextMonth"));

        }else{
            // when Init
            $(document).ready(function(){
                $.each(eventsMap, function(index, value){
                    var newEvent = {
                        id : value.Id,
                        title : value.title,
                        start : moment(value.startDateTime),
                        allDay: true,
                        description : value.description,
                        owner : value.owner,
                        backgroundColor : value.backgroundColor
                    }
                    eventArray.push(newEvent);
                });
                var calendarButtons = '';
                $('#calendar').fullCalendar({
                    header: {
//                        left: 'today prev,next',
                        left: '',
                        center: 'title',
                        right: 'prev,next'
                    },
                    defaultDate: moment().format("YYYY-MM-DD HH:mm:ss"),
                    navLinks: false,
                    editable: false,
                    eventLimit: true,
                    weekends: component.get('v.weekends'),
                    eventBackgroundColor: component.get('v.eventBackgroundColor'),
                    eventBorderColor: component.get('v.eventBorderColor'),
                    eventTextColor: component.get('v.eventTextColor'),
                    events: eventArray,
                    eventOrder: 'backgroundColor,start'

                });
                $('#calendar').fullCalendar('gotoDate', component.get("v.DateNextMonth"));
            });
        }
    },
})