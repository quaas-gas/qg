class @Dashboard extends React.Component
  @propTypes =
    deliveries: React.PropTypes.array

  render: ->
    deliveries = @props.deliveries
    `<div>
      <h1>Startseite</h1>
      <div className="row">
        <div className="col-md-4">
          <h3>Letzte Lieferungen</h3>

          <table className="table table-hover table-condensed table-clickable">
            <tbody>
              {deliveries.map( (delivery) => <DashboardDeliveryLine delivery={delivery} key={delivery.id} />)}
              </tbody>
          </table>
        </div>

      </div>
    </div>`
