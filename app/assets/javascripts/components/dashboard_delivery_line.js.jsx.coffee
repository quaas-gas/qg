class @DashboardDeliveryLine extends React.Component
  @propTypes =
    delivery: React.PropTypes.object

  render: ->
    delivery = @props.delivery
    `<tr data-url="" class="">
      <td></td>
      <td>{delivery.number}</td>
      <td>{delivery.date}</td>
      <td></td>
    </tr>`
