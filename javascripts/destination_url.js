var i = 0;
var t = 0;

function runQuery(account) {

  MccApp.select(account);
  report = AdWordsApp.report(
      "SELECT AccountDescriptiveName,Device,ClickType,Date,CampaignName,EffectiveDestinationUrl,Clicks,Impressions,Cost " +
        " FROM DESTINATION_URL_REPORT " +
        " WHERE " + 
          " Impressions > " + t + 
        " DURING YESTERDAY");

  Logger.log(++i);
  return report;
}

function main(){
    var accountSelector = MccApp.accounts();
    var accountIterator = accountSelector.get();

    var data = [];
    var csv = 'CustomerId,AccountDescriptiveName,Device,ClickType,Date,CampaignName,EffectiveDestinationUrl,Clicks,Impressions,Cost';
    while(accountIterator.hasNext()){

      var account = accountIterator.next();
      var customerId = account.getCustomerId();

      var report = runQuery(account);
      var report_iter = report.rows();
      while(report_iter.hasNext()) {
        var row = report_iter.next();
        var col=[ customerId,
                  row['AccountDescriptiveName'],
                  row['Device'],
                  row['ClickType'],
                  row['Date'],
                  row['CampaignName'],
                  row['EffectiveDestinationUrl'],
                  row['Clicks'],
                  row['Impressions'],
                  row['Cost']
                 ];
        csv += '\n' + col.join(',');
      }
    }
   var formattedDate = Utilities.formatDate(new Date(), 'GMT', 'yyyy-MM-dd');
   Logger.log(formattedDate);
   var fileName = "daily_destinationUrl_performance_" + formattedDate;

  var folders = DriveApp.getFolders();
  while (folders.hasNext()) {
     var folder = folders.next();
     if(folder.getName()=='Adwords'){
        folder.createFile(fileName, csv, MimeType.CSV);
     };
 }
  
}
